use Test;

use Documentable::Registry;
use Documentable::DocPage::Index;

plan *;

my $registry = Documentable::Registry.new(
    :topdir("t/test-doc"),
    :dirs(["Type"]),
    :!verbose
);

$registry.compose;

my @programs-index = (
    %(:name("Debugging"), :url("/programs/01-debugging"), :summary("debugging")),
);
my @language-index = (
    %(:name("Terms")    , :url("/language/terms")       , :summary("terms")    ),
    %(:name("Operators"), :url("/language/operators")   , :summary("operators") ),
);
my @type-index = (
    %(:name("Any"), :url("/type/Any"), :subkinds(("class",)), :summary("any"), :subkind("class")),
);
my @routine-index = (
    %(:name("index-language"), :url("/routine/index-language"), :subkinds(("method",)), :origins((("Language", "/language/language"),))),
    %(:name("index-programs"), :url("/routine/index-programs"), :subkinds(("method",)), :origins((("Programs", "/programs/programs"),))),
    %(:name("index-types")   , :url("/routine/index-types")   , :subkinds(("method",)), :origins((("Any"     , "/type/Any"         ),)))
);

my @index;
subtest "Main index generation" => {
    @index = Documentable::DocPage::Index::Programs.new.compose($registry);
    test-index(@index, @programs-index, "program index" );
    @index = Documentable::DocPage::Index::Language.new.compose($registry);
    test-index(@index, @language-index, "language index");
    @index = Documentable::DocPage::Index::Type.new.compose($registry);
    test-index(@index, @type-index    , "type index"    );
    @index = Documentable::DocPage::Index::Routine.new.compose($registry);
    test-index(@index, @routine-index, "routine index"  );
};

my @type-subindex := (
    %(:name("Any"), :url("/type/Any"), :subkinds(("class",)), :summary("types"), :subkind("class")),
);
my @routine-subindex := (
    %(:subkinds(("method",)), :name("index-language"), :url("/routine/index-language"), :origins((("Language", "/language/language"),))),
    %(:subkinds(("method",)), :name("index-programs"), :url("/routine/index-programs"), :origins((("Programs", "/programs/programs"),))),
    %(:subkinds(("method",)), :name("index-types"   ), :url("/routine/index-types"   ), :origins((("Any"     , "/type/Any"         ),)))
);

subtest "Subindex generation" => {
    @index = Documentable::DocPage::SubIndex::Type.new.compose($registry, "type");
    test-index(@index, @type-subindex   , "type subindex"   );
    @index = Documentable::DocPage::SubIndex::Routine.new.compose($registry, "method");
    test-index(@index, @routine-subindex, "routine subindex");
}

sub test-index(@index, @expected, $msg) {
    subtest $msg => {
        for @index -> %entry {
            test-index-entry(@index, %entry);
        }
    }
}

sub test-index-entry (@index, %entry){
    my $found = False;
    for @index -> %expected-entry {
        if (%expected-entry eq %entry) {
            $found = True;
        }
    }
    is $found, True, "{%entry.<name>} found";
}

done-testing;
