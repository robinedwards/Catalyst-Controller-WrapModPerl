package Apache::DumbRequest;
use Moose;
use Apache::DumbHeader;

has context=>(isa=>'Object', is=>'ro', handles=>[qw/session delete_session/]);

has request=>(isa=>'Object', is=>'rw', handles=>{
        param => 'param',
        parsed_uri => 'uri',
        method => 'method',
        content => 'body'
    });

has headers_in => (isa=>'Apache::DumbHeader',  is=>'rw' );

has headers_out => (isa=>'Apache::DumbHeader',  is=>'rw', 
    handles=>{
        send_http_header=>'send',
    }
);

has handle=>(isa=>'IO::Scalar', is=>'ro', required=>1);

sub BUILD {
    my ($self) = @_;
    $self->request($self->context->request);

    $self->headers_in(Apache::DumbHeader->new(
            http_header=>$self->request->headers)
    );
    
    $self->headers_out(Apache::DumbHeader->new(
            http_header=>$self->context->response->headers)
    );
}

sub pnotes {}

sub args {
    my ($self) = @_;

    return wantarray ? %{ $self->request->query_parameters } 
                     : $self->request->uri->query;
}

sub uri {
    $_[0]->request->uri;
}

1;
