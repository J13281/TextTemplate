package TextTemplate;

use v5.36;

use Exporter 'import';
our @EXPORT_OK = qw(transform);

sub transform($obj, $temp) {
    my $nodes = parse($temp);
    return fmt($obj, $nodes);
}

# private
sub parse($in) {
    my $qr = qr/%>|<%.+?,/;
    my $d = [split2($qr, $in)];
    my $e = ['<%__ROOT__,', @$d, '%>'];
    my $f = rec($e, 0);
    return $$f{nodes};
}

sub split2($qr, $in) {
    my @ans, my $left = 0;
    while ($in =~ /$qr/g) {
        push @ans, substr($in, $left, $-[0] - $left) if $-[0] - $left;
        push @ans, substr($in, $-[0], $+[0] - $-[0]) if $+[0] - $-[0];
        $left = $+[0];
    }
    push @ans, substr($in, $left, length($in)) if $left - length($in);
    return @ans;
}

sub rec($d, $i) {
    return $i, undef if $$d[$i] eq "%>";
    return $i, $$d[$i] unless $$d[$i] =~ "<%";

    my ($e, $v, $j);
    $j = $i;
    while (($j, $v) = rec($d, $j + 1), $v) {
        push(@$e, $v);
    }
    my ($var) = $$d[$i] =~ /<%(.+),/;
    return $j, { var => $var, nodes => $e };
}

sub fmt($var, $nodes) {
    return
        ref $var eq "ARRAY" ? fmtArray($var, $nodes) :
        ref $var eq "HASH" ? fmtHash($var, $nodes) :
        die;
}

sub fmtArray($var, $nodes) {
    my @d = map { fmt($_, $nodes) } @$var;
    return join("", @d);
}

sub fmtHash($var, $nodes) {
    my @defines = map {
        sprintf 'my $%s = $$var{%s};', $_, $_;
    } keys %$var;

    my @codes;
    for (my $i = 0; $i < @$nodes; $i++) {
        if (ref $$nodes[$i]) {
            push @codes, sprintf 'fmt(%s, $$nodes[%s]{nodes})', $$nodes[$i]{var}, $i;
        }
        else {
            push @codes, qqe($$nodes[$i]);
        }
    }

    return eval join("", @defines).join(".", @codes);
}

sub qqe($in) {
    $in =~ s/"/\\"/g;
    return qq/"$in"/;
}

1;