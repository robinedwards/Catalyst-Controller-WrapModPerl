use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Catalyst::Controller::WrapModPerl',
    VERSION_FROM      => 'lib/Catalyst/Controller/WrapModPerl.pm', # finds $VERSION
    PREREQ_PM         => {
        Config::ApacheFormat => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Catalyst/Controller/WrapModPerl.pm', # retrieve abstract from module
       AUTHOR         => 'Robin Edwards <robin.ge@gmail.com>') : ()),
);
