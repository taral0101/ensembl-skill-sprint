package ClinVarFlag;
use strict;
use warnings;
use base qw(Bio::EnsEMBL::Variation::Utils::BaseVepPlugin);

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    return $self;
}

# We operate on raw VariationFeature objects
sub feature_types {
    return ['VariationFeature'];
}

# Declare our new INFO field
sub get_header_info {
    return {
        ClinVar_Pathogenic => '1 if CLNSIG contains "Pathogenic"'
    };
}

# Core logic: inspect CLNSIG and flag if it contains “Pathogenic”
sub run {
    my ($self, $vf, $line_hash) = @_;
    my $clin = $line_hash->{INFO}{CLNSIG} || '';
    if ($clin =~ /Pathogenic/) {
        return { ClinVar_Pathogenic => 1 };
    }
    return {};
}

1;
