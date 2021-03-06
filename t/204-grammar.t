use Test;

use Documentable;
use Documentable::Heading::Grammar;
use Documentable::Heading::Actions;
use Pod::Utilities; #! delete

plan *;

for <infix prefix postfix circumfix listop> {
    test-definition($_, "foo", Kind::Routine, $_, "operator", "The foo $_");
    test-definition($_, "\{ \}", Kind::Routine, $_, "operator", "$_ \{ \}"    );
}

for <sub method term routine submethod trait> {
    test-definition($_, "foo", Kind::Routine, $_, $_, "The foo $_");
    test-definition($_, "foo", Kind::Routine, $_, $_, "$_ foo"    );
}

for <constant variable twigil declarator quote> {
    test-definition($_, "foo", Kind::Syntax, $_, $_, "The foo $_");
    test-definition($_, "foo", Kind::Syntax, $_, $_, "$_ foo"    );
}

subtest "name with whitespaces" => {
    test-definition("trait", "is export", Kind::Routine, "trait", "trait", "trait is export");
    test-definition("term", '{ }', Kind::Routine, "term", "term", 'term { }');
}

sub test-definition($infix, $name, $kind, $subkind, $category, $line) {
    subtest "$infix detection" => {
        my $g = parse-definition($line);
        is $g.dname    , $name    , "name detected";
        is $g.dkind    , $kind    , "kind detected";
        is $g.dsubkind , $subkind , "subkind detected";
        is $g.dcategory, $category, "category detected";
    }
}

sub parse-definition($line) {
    Documentable::Heading::Grammar.parse(
        $line,
        :actions(Documentable::Heading::Actions.new)
    ).actions;
}

done-testing;