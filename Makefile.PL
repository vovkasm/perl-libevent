use ExtUtils::MakeMaker;

my $libevent_libs = `pkg-config --libs libevent`;
my @libs = ($libevent_libs, '-levent');

WriteMakefile(
    NAME => 'LibEvent',
    VERSION_FROM => 'lib/LibEvent.pm',
    AUTHOR => 'Vladimir Timofeev <vovkasm@gmail.com>',
    LICENSE => 'perl',
    BUILD_REQUIRES => {
        'Test::More' => 0.88,
        'Test::Fatal' => 0,
    },
    PREREQ_PM => {
        'Sub::Exporter' => 0,
    },
    LIBS => [@libs],
    depend => {
        'LibEvent.xs' => 'base.xsi simple-events.xsi',
    },
);
