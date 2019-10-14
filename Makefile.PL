use 5.020003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Rax',
    VERSION_FROM      => 'lib/Rax.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    ABSTRACT_FROM     => 'lib/Rax.pm', # retrieve abstract from module
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    AUTHOR            => 'Dylan Hardison <dylan@local>',
    LICENSE           => 'bsd',
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-Irax -I.', # e.g., '-I. -I/usr/include/other'
    OBJECT            => '$(O_FILES) rax_core.o', # link all the C files too
);

sub MY::postamble {
  return join("\n",
    "rax_core.c: rax/rax.c",
    "\tcp \$< \$@"
  ) . "\n";
}
