#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use Data::Dumper;
use FindBin qw($Bin);


GetOptions (\%opt,"ref:s","step:s","head","1:s","2:s","help");


my $help=<<USAGE;


USAGE


if ($opt{help} or keys %opt < 1){
    print "$help\n";
    exit();
}

my $bismark="/rhome/cjinfeng/software/tools/bismark_v0.8.3";
#######Step 1###############################################
if($opt{step}=~/1/){
if ($opt{ref}){
   print "Preparing genome ......\n";
   `mkdir reference` unless (-e "reference");
   `ln -s $opt{ref} ./reference/genome.fasta` unless (-e "./reference/genome.fasta");
   `$bismark/bismark_genome_preparation --path_to_bowtie /usr/local/bin/ --verbose ./reference/` unless (-e "./reference/Bisulfite_Genome");
   print "Done\n";
}else{
   print "Genome sequence not specified, using --ref\n";
   exit();
}
}
#######Step 2##############################################
if ($opt{step}=~/2/){
if ($opt{1} and $opt{2}){
   print "Bisulfite mapping ......\n";
   if ($opt{head}){
      `$bismark/bismark ./reference/ -1 $opt{1} -2 $opt{2}`;
   }else{
      `$bismark/bismark --sam-no-hd ./reference/ -1 $opt{1} -2 $opt{2}`;
   }
   print "Done\n";
}elsif($opt{1}){
   print "Bisulfite mapping ......\n";
   if ($opt{head}){
      `$bismark/bismark ./reference/ $opt{1}`;
   }else{
      `$bismark/bismark --sam-no-hd ./reference/ $opt{1}`;
   }
   print "Done\n";
}
}

###########################################################
sub readtable
{
my ($file)=@_;
my %hash;
open IN, "$file" or die "$!";
while(<IN>){
    chomp $_;
    next if ($_=~/^$/);
    my @unit=split("\t",$_);
    $hash{$unit[0]}=1;
}
close IN;
return \%hash;
}
 
