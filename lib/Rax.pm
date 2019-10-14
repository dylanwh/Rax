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

Rax - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Rax;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Rax, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Dylan Hardison, E<lt>dylan@localE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Dylan Hardison

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
