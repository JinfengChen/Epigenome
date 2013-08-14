#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use Data::Dumper;
use FindBin qw($Bin);


GetOptions (\%opt,"ref:s","step:s","read:s","cpu:s","linker3:s","linker5:s","help");


my $help=<<USAGE;
perl $0 --read ERRR000077.fastq.gz

USAGE


if ($opt{help} or keys %opt < 1){
    print "$help\n";
    exit();
}

$opt{ref} ||="/rhome/cjinfeng/BigData/00.RD/seqlib/MSU_r7.fa";
$opt{cpu} ||=1;
$opt{step} ||="12";
###### yizhou 3' adaptor TGGAATTCTCGGGTGCCAAGGC
###### Zimberman 3' adaptor CTGTAGGCACCATCAAT  5' adaptor ACACTCTTTCCCTACACGACGCTGTTCCATCT
$opt{linker3} ||="ATCTCGTATGCCGTCTTCTGCTTG"; ###Illumina_Small_RNA_3p_Adapter_1
$opt{linker5} ||="GTTCAGAGTTCTACAGTCCGACGATC"; ###Illumina_Small_RNA_Adapter_1
my $bwa="/opt/tyler/bin/bwa";
my $SAMtool="/usr/local/bin/samtools";
my $fastx_clipper="/usr/local/bin/fastx_clipper";
#######Step 1###############################################
my $prefix="";
if($opt{step}=~/1/){
  print "Trim adaptor: $opt{read} ......\n";
  $prefix=basename($opt{read},".fastq.gz");
  `zcat $opt{read} | $fastx_clipper -a $opt{linker3} -l 12 -Q 33 -v -c -z -o $prefix.trim3.fastq.gz > $prefix.trim3.log 2> $prefix.trim3.log2` unless (-e "$prefix.trim3.fastq.gz");
  `zcat $prefix.trim3.fastq.gz | $fastx_clipper -a $opt{linker5} -l 12 -Q 33 -v -z -o $prefix.trim3_5.fastq.gz > $prefix.trim3_5.log 2> $prefix.trim3_5.log2` unless (-e "$prefix.trim3_5.fastq.gz");
  print "Done\n";
}
#######Step 2##############################################
if ($opt{step}=~/2/){
  print "Mapping reads ......\n";
  `$bwa aln -t $opt{cpu} $opt{ref} $prefix.trim3_5.fastq.gz > $prefix.trim3_5.sai` unless (-e "$prefix.trim3_5.sai");
  `$bwa samse $opt{ref} $prefix.trim3_5.sai $prefix.trim3_5.fastq.gz > $prefix.trim3_5.sam` unless (-e "$prefix.trim3_5.sam");
  `$SAMtool view -bS -o $prefix.trim3_5.raw.bam $prefix.trim3_5.sam` unless (-e "$prefix.trim3_5.raw.bam");
  `$SAMtool sort $prefix.trim3_5.raw.bam $prefix.trim3_5` unless (-e "$prefix.trim3_5.bam");
  print "Done\n";
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
 
