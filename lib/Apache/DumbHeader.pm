package Apache::DumbHeader;
use Moose;

has http_header=>(isa=>'Object', is=>'ro', required=>1, handles=>{get=>'header',set=>'header'});

sub send { 
    my ($self,$type) = @_;
    $self->set('Content-Type', $type);
}
1;
