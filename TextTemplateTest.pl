use lib ".";
use TextTemplate qw(transform);

my $in = <<'eof';
<html>
    <%$info,
    <ul class="$cls">
        <%$users,
        <li class="$k">$v</li>
        %>
    </ul>
    %>
</html>
eof

my $obj = {
    info => {
        cls => "takahiro",
        users => [
            { k=> "aaa", v => "hello1" },
            { k=> "bbb", v => "hello2" },
            { k=> "ccc", v => "hello3" },
        ]
    }
};

print transform($obj, $in);
# output::
=pod
<html>
    
    <ul class="takahiro">
        
        <li class="aaa">hello1</li>
        
        <li class="bbb">hello2</li>
        
        <li class="ccc">hello3</li>
        
    </ul>
    
</html>
=cut
