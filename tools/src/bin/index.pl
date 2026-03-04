#!/usr/bin/perl -w

use v5.30;
use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8);
use Cwd;
use FindBin qw($RealBin);
use Term::ANSIColor qw(:constants);
use File::Path qw(make_path);
use File::Copy qw(copy);
use POSIX qw(strftime);

# Adicionar caminhos para os módulos
use lib "$RealBin/../lib";
use TheWord::Validate;
use TheWord::Logger;
use TheWord::Config;
use TheWord::Preview;
use TheWord::Format;
use TheWord::Convert;
use TheWord::Merge;

our $VERSION = '1.1.1';

# Configuração global
my $config = TheWord::Config->new();
my $logger = TheWord::Logger->new(
    level => $config->get_config('log_level') eq 'DEBUG' ? TheWord::Logger::LEVEL_DEBUG : TheWord::Logger::LEVEL_INFO,
    console => $config->get_config('log_console') // 1,
    colors => $config->get_config('log_colors') // 1,
);
my $validator = TheWord::Validate->new(debug => ($config->get_config('log_level') eq 'DEBUG'));
my $preview = TheWord::Preview->new(width => 80, format_mode => 'console');

# Forçar UTF-8 para entrada/saída
binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

# Decodificar argumentos
@ARGV = map { decode_utf8($_) } @ARGV;

sub main {
    my ($book_name, $chapter_verses, $options) = parse_arguments(@ARGV);
    
    if ($options->{help} || !$book_name) {
        print_help();
        exit 0;
    }
    
    print_header();
    
    # Validar parâmetros
    my $param_result = $validator->validate_parameters($book_name, $chapter_verses);
    if (!$param_result->{valid}) {
        print BOLD RED "❌ ERRO: Parâmetros inválidos\n" . RESET;
        print $validator->format_errors($param_result->{errors});
        exit 1;
    }
    
    # Definir caminhos
    my $file_input_verses = $config->get_file_path('input_verses');
    my $file_input_notes = $config->get_file_path('input_notes');
    my $file_edit_verses = $config->get_file_path('edit_verses');
    my $file_edit_notes = $config->get_file_path('edit_notes');
    my $file_merged = $config->get_file_path('merged');
    
    # Criar output dir
    make_path(dirname($file_merged)) unless -d dirname($file_merged);
    
    # Validar entradas
    my $files_result = $validator->validate_input_files($file_input_verses, $file_input_notes);
    if (!$files_result->{valid}) {
        print BOLD RED "❌ ERRO: Arquivos de entrada inválidos\n" . RESET;
        print $validator->format_errors($files_result->{errors});
        exit 1;
    }
    
    # 1. Formatar arquivos de edição se necessário
    $logger->info("Preparando arquivos de edição");
    open(my $iv, '<:utf8', $file_input_verses) or die $!;
    my $verses_raw = do { local $/; <$iv> };
    close $iv;
    
    open(my $in, '<:utf8', $file_input_notes) or die $!;
    my $notes_raw = do { local $/; <$in> };
    close $in;
    
    create_or_update_edit_file($file_edit_verses, TheWord::Format::verses($verses_raw), "versículos");
    create_or_update_edit_file($file_edit_notes, TheWord::Format::notes($notes_raw), "notas");
    
    # 2. Pausa para edição (se interativo)
    if ($options->{interactive}) {
        interactive_editing_pause();
    }
    
    # 3. Realizar Merge
    $logger->info("Gerando merged.txt");
    open(my $ev, '<:utf8', $file_edit_verses) or die $!;
    my @edit_verses = <$ev>;
    close $ev;
    
    open(my $en, '<:utf8', $file_edit_notes) or die $!;
    my @edit_notes = <$en>;
    close $en;
    
    my $result = TheWord::Merge::content($book_name, $chapter_verses, join('', @edit_verses), join('', @edit_notes));
    
    open(my $out, '>:utf8', $file_merged) or die $!;
    print $out $result;
    close $out;
    
    print BOLD GREEN "✅ Sucesso! Arquivo gerado em $file_merged\n" . RESET;
}

sub parse_arguments {
    my @args = @_;
    my %options = ( help => 0, interactive => 1 );
    my @params;
    for my $arg (@args) {
        if ($arg =~ /^-h|--help$/) { $options{help} = 1; }
        elsif ($arg =~ /^-n|--no-interactive$/) { $options{interactive} = 0; }
        elsif ($arg !~ /^-/) { push @params, $arg; }
    }
    return ($params[0], $params[1], \%options);
}

sub create_or_update_edit_file {
    my ($file, $content, $type) = @_;
    if (!-f $file || -z $file) {
        open(my $fh, '>:utf8', $file) or die $!;
        print $fh $content;
        close $fh;
    }
}

sub interactive_editing_pause {
    print BOLD YELLOW "\n⏸️  PAUSA PARA EDIÇÃO MANUAL\n" . RESET;
    print "Pressione ENTER após editar os arquivos em output/: ";
    <STDIN>;
}

sub print_header { print BOLD CYAN "TheWord - Processador Família 35 v$VERSION\n" . RESET; }

sub print_help {
    print "USO: perl index.pl [LIVRO] [CAPÍTULO:VERSÍCULOS]\n";
}

sub dirname { my $p = shift; $p =~ s/[^\/\\]+$//; return $p || './'; }

main();
