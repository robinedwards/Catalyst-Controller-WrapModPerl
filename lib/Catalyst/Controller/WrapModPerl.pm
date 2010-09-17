package Catalyst::Controller::WrapModPerl;
use 5.008008;
use Moose;
use mro 'c3';
use IO::Scalar;
use Try::Tiny;
use Apache::DumbRequest;

extends 'Catalyst::Controller';

use namespace::clean -except => 'meta';

our $VERSION = '0.001';

sub wrap_handler {
    my ($self, $c, $module) = @_;
    
    eval "require $module";
    die "failed to load handler: $@" if $@;

    my $content;
    my $OH = new IO::Scalar \$content;

    my $req = Apache::DumbRequest->new( context => $c, handle => $OH);

    try { 
        $c->res->status($module->can("handler")->($req));
    }
    catch {
        $c->error($_);
    };


    $c->res->body($content) unless length $c->res->body;
    
    # probably trying to redirect so set 302 if no code
    my $location = $req->headers_out->get('Location');
    if (defined $location && length $location && $c->res->status == 200) {
        $c->res->status(302);
    }  

    $c->res->headers($req->headers_out->http_header);
}

1;
__END__

=head1 NAME

Catalyst::Controller::WrapModPerl - Perl extension for blah blah blah

=head1 SYNOPSIS


=head1 DESCRIPTION

Stub documentation for Catalyst::Controller::WrapModPerl, created by h2xs. It looks like the
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

Rob Edwards, E<lt>robin.ge@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Rob Edwards

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
