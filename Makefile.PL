use 5.020003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Rax',
    VERSION_FROM      => 'lib/Rax.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Rax.pm', # retrieve abstract from module
    AUTHOR            => 'Dylan Hardison <dylan@local>',
    LICENSE           => 'bsd',
    #Value must be from legacy list of licenses here
    #http://search.cpan.org/perldoc?Module%3A%3ABuild%3A%3AAPI
    LIBS              => ['-lm'],
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-Irax -I.', # e.g., '-I. -I/usr/include/other'
    OBJECT            => '$(O_FILES) rax/rax.o', # link all the C files too
);

sub MY::postamble {
  return <<'MAKE';
rax/rax.o: rax/Makefile rax/rax.c rax/rax.h
	cd rax && $(MAKE) rax.o
MAKE
}
