use Test::More import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;
use Dancer::Route;

plan tests => 25;

eval { prefix 'say' };
like $@ => qr/not a valid prefix/, 'prefix must start with a /';

{
    prefix '/say' => 'prefix defined';

    get '/foo'  => sub { 'it worked' };

    get '/foo/' => sub { 'it worked' };

    get '/:char' => sub {
        pass and return false if length( params->{char} ) > 1;
        "char: " . params->{char};
    };

    get '/:number' => sub {
        pass and return false if params->{number} !~ /^\d+$/;
        "number: " . params->{number};
    };

    prefix '/lex' => sub {
      get '/foo'  => sub { 'it worked' };
    };

    any '/any' => sub {"any"};

    get qr{/_(.*)} => sub {
        "underscore: " . params->{splat}[0];
    };

    get '/:word' => sub {
        pass and return false if params->{word} =~ /trash/;
        "word: " . params->{word};
    };

    get '/' => sub {
        "char: all";
    };

    prefix(undef);

    prefix '/dura' => sub {
      get '/us'  => sub { 'us worked' };
    };

    get '/*' => sub {
        "trash: " . params->{splat}[0];
    };
}

my @tests = (
    { path => '/say/',        expected => 'char: all' },
    { path => '/say/A',       expected => 'char: A' },
    { path => '/say/24',      expected => 'number: 24' },
    { path => '/say/B',       expected => 'char: B' },
    { path => '/say/Perl',    expected => 'word: Perl' },
    { path => '/say/_stuff',  expected => 'underscore: stuff' },
    { path => '/say/any',     expected => 'any' },
    { path => '/go_to_trash', expected => 'trash: go_to_trash' },
    { path => '/say/foo',     expected => 'it worked' },
    { path => '/say/foo/',    expected => 'it worked' },
    { path => '/lex/foo',     expected => 'it worked' },
    { path => '/dura/us',     expected => 'us worked' },
);

foreach my $test (@tests) {
    my $path     = $test->{path};
    my $expected = $test->{expected};

    response_status_is         [GET => $path] => 200;
    response_content_is_deeply [GET => $path] => $expected;
}

