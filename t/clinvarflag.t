#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

BEGIN {
    # Ensure the local plugin directory is available during testing.
    unshift @INC, "$FindBin::Bin/../plugins";

    # Minimal stub of the VEP base plugin class so the plugin logic can be
    # tested without requiring a full VEP installation in the test runner.
    package Bio::EnsEMBL::Variation::Utils::BaseVepPlugin;
    sub new {
        my ($class, $config) = @_;
        return bless { config => $config }, $class;
    }
}

use Test::More;
use ClinVarFlag;

my $plugin = ClinVarFlag->new({});

subtest 'Pathogenic significance is flagged' => sub {
    my $line_hash = { INFO => { CLNSIG => 'Pathogenic' } };
    my $result = $plugin->run(undef, $line_hash);
    is($result->{ClinVar_Pathogenic}, 1, 'Pathogenic variant receives flag');
};

subtest 'Combined pathogenic significance is flagged' => sub {
    my $line_hash = { INFO => { CLNSIG => 'Pathogenic/Likely_pathogenic' } };
    my $result = $plugin->run(undef, $line_hash);
    is($result->{ClinVar_Pathogenic}, 1, 'Combined pathogenic classification receives flag');
};

subtest 'Benign significance is not flagged' => sub {
    my $line_hash = { INFO => { CLNSIG => 'Benign' } };
    my $result = $plugin->run(undef, $line_hash);
    ok(!exists $result->{ClinVar_Pathogenic}, 'Benign variant is not flagged');
};

subtest 'Missing CLNSIG is handled safely' => sub {
    my $line_hash = { INFO => {} };
    my $result = $plugin->run(undef, $line_hash);
    ok(!exists $result->{ClinVar_Pathogenic}, 'Missing CLNSIG does not create a false positive');
};

done_testing();
