package Rax;

use 5.020003;
use warnings;
use Rax::Iterator;

sub seek {
  my $self = shift;
  my $iter = $self->iter;
  $iter->seek(@_);
  return $iter;
}

sub keys {
  my $self = shift;
  my $iter = $self->iter->seek('^');
  my @keys;

  while (my $key = $iter->next) {
    push @keys, $key;
  }

  return @keys;
}

sub values {
  my $self = shift;
  my $iter = $self->iter->seek('^');
  my @values;

  while (my (undef, $value) = $iter->next) {
    push @values, $value;
  }

  return @values;
}

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

our $VERSION = '1.00';

require XSLoader;
XSLoader::load('Rax', $VERSION);

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Rax - Perl extension for rax, A radix tree implementation in ANSI C.

=head1 SYNOPSIS

  use Rax;
  my $rax = Rax->new({ apple => 1, banana => undef });

  is($rax->find("apple"), 1);
  is($rax->find("banana"), undef);
  is($rax->find("cherry"), undef);
  ok($rax->exists("banana"));
  ok(! $rax->exists("cherry") )

=head1 DESCRIPTION

Rax is a radix tree implementation initially written to be used in a specific
place of Redis in order to solve a performance problem, but immediately
converted into a stand alone project to make it reusable for Redis itself,
outside the initial intended application, and for other projects as well.

The primary goal was to find a suitable balance between performances and memory
usage, while providing a fully featured implementation of radix trees that can
cope with many different requirements.

=head1 SEE ALSO

L<https://github.com/antirez/rax>

=head1 AUTHOR

Dylan Hardison, E<lt>dylan@hardison.netE<gt>

I just wrote the glue to make this usable from perl.

=head1 COPYRIGHT AND LICENSE

This perl binding is copyright (c) 2019 by Dylan Hardison.

It wraps the "rax" library which is copyright (c) 2017, Salvatore Sanfilippo <antirez@gmail.com>

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

=over 4

=item *

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

=item *

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

=over

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
