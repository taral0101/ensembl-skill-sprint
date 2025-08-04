#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

BEGIN {
    # 1) Ensure our plugins folder is in @INC
    unshift @INC, "$FindBin::Bin/../plugins";
    # 2) Stub out the VEP BaseVepPlugin class so inheritance works
    package Bio::EnsEMBL::Variation::Utils::BaseVepPlugin;
    sub new {
        my ($class, $config) = @_;
        return bless { config => $config }, $class;
    }
}

use Test::More tests => 2;
use ClinVarFlag;

my $plugin = ClinVarFlag->new({});

# Test 1: Pathogenic → flagged
{
    my $lh = { INFO => { CLNSIG => 'Pathogenic' } };
    my $res = $plugin->run(undef, $lh);
    ok( $res->{ClinVar_Pathogenic} == 1, 'Pathogenic → flagged' );
}

# Test 2: Benign → not flagged
{
    my $lh = { INFO => { CLNSIG => 'Benign' } };
    my $res = $plugin->run(undef, $lh);
    ok( !exists $res->{ClinVar_Pathogenic}, 'Benign → not flagged' );
}
