package Catalyst::Controller::ApacheLocations;
use 5.008008;
use Moose;
use mro 'c3';
extends 'Catalyst::Controller::WrapModPerl';
use Config::ApacheFormat;
use namespace::clean -except => 'meta';

our $VERSION = '0.001';

sub _stats_start_execute {
    my ( $self, $c, $action_name ) = @_;

    my $appclass = ref($c) || $c;
    $c->counter->{$action_name}++;

    my $action = $action_name;
    $action = "/$action" unless $action =~ /->/;

    # determine if the call was the result of a forward
    # this is done by walking up the call stack and looking for a calling
    # sub of Catalyst::forward before the eval
    my $callsub = q{};
    for my $index ( 2 .. 11 ) {
        last
        if ( ( caller($index) )[0] eq 'Catalyst'
            && ( caller($index) )[3] eq '(eval)' );

        if ( ( caller($index) )[3] =~ /forward$/ ) {
            $callsub = ( caller($index) )[3];
            $action  = "-> $action";
            last;
        }
    }

    my $uid = $action_name . $c->counter->{$action_name};

    # is this a root-level call or a forwarded call?
    if ( $callsub =~ /forward$/ ) {
        my $parent = $c->stack->[-1];

        # forward, locate the caller
        if ( exists $c->counter->{"$parent"} ) {
            $c->stats->profile(
                begin  => $action,
                parent => "$parent" . $c->counter->{"$parent"},
                uid    => $uid,
            );
        }
        else {

            # forward with no caller may come from a plugin
            $c->stats->profile(
                begin => $action,
                uid   => $uid,
            );
        }
    }
    else {

        # root-level call
        $c->stats->profile(
            begin => $action,
            uid   => $uid,
        );
    }
    return $action;
}

sub register_actions {
    my ($self, $app) = @_;

    my $namespace = $self->action_namespace($app);
    my $conf = $self->load_locations;

    for my $loc (keys %$conf) {
        my $attr = { Path=> [$loc ] };
        $attr = { Regex =>[ $loc ]} if ($conf->{$loc}{regex});
       
        # wrap each handler for the location 
        my $code = sub {
            my ($controller, $c) = @_;

            for my $handler (@{$conf->{$loc}{handler}}){
                warn "executing handler $handler\n";

                my $stats_info = $self->_stats_start_execute($c,  $handler ) if $c->use_stats;

                eval { $controller->wrap_handler($c, $handler) };

                my $e = $@;
                $c->_stats_finish_execute( $stats_info ) if $c->use_stats and $stats_info;
                die $e if $e;
            }
        };

        my $reverse = $namespace ? "$namespace/$loc" : $loc;

        my $action = $self->create_action(
            name       => $loc,
            code       => $code,
            reverse    => $reverse,
            namespace  => $namespace,
            class      => ref $self,
            attributes => $attr,
        );

        $app->dispatcher->register($app, $action);
    }

    $self->next::method($app, @_);
}
