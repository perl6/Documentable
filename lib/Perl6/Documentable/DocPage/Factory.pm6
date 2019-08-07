unit module Perl6::Documentable::DocPage::Factory;

use Perl6::Documentable;
use Pod::Load;
use Perl6::Documentable::Config;
use Perl6::Documentable::Utils::IO;
use Perl6::Documentable::Registry;

# html generation
use Perl6::Documentable::To::HTML::Wrapper;
use Perl6::Documentable::DocPage::Source;
use Perl6::Documentable::DocPage::Kind;
use Perl6::Documentable::DocPage::Index;

class Perl6::Documentable::DocPage::Factory {

   has Perl6::Documentable::Config $.config;
   has Perl6::Documentable::Registry $.registry;
   has Perl6::Documentable::To::HTML::Wrapper $.wrapper;

    method BUILD(
        Perl6::Documentable::Config :$config,
        Perl6::Documentable::Registry :$registry
    ) {
        $!registry = $registry;
        $!wrapper = Perl6::Documentable::To::HTML::Wrapper.new(
            menu-entries => $config.menu-entries
        )
    }

    method generate-home-page() {
        my $pod = load($!registry.topdir~"/HomePage.pod6")[0];
        %(
          document => $!wrapper.render($pod, :pod-path("HomePage.pod6")),
          url => '/index'
          )
    }

    method generate-error-page() {
        my $pod = load($!registry.topdir~"/404.pod6")[0];
        %(
          document => $!wrapper.render($pod, :pod-path("404.pod6")),
          url => '/404'
          )
    }

    method generate-primary($doc) {
        my %pod-to-render = do given $doc.kind {
            when Kind::Type {
                Perl6::Documentable::DocPage::Source::Type.new.render($!registry, $doc.name);
            }
            when Kind::Language {
                Perl6::Documentable::DocPage::Source::Language.new.render($!registry, $doc.name);
            }
            when Kind::Programs {
                Perl6::Documentable::DocPage::Source::Programs.new.render($!registry, $doc.name);
            }
        }

        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $doc.kind.gist,
                                         :pod-path-from-url($doc.url)
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }

    method generate-secondary(Kind $kind, Str $name) {
        my %pod-to-render = Perl6::Documentable::DocPage::Kind.new.render($!registry, $name, $kind);
        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $kind.gist,
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }

    method generate-index(Kind $kind, $manage?) {
        my %pod-to-render = do given $kind {
            when Kind::Type {
                Perl6::Documentable::DocPage::Index::Type.new.render($!registry);
            }
            when Kind::Language {
                Perl6::Documentable::DocPage::Index::Language.new.render($!registry, $manage);
            }
            when Kind::Programs {
                Perl6::Documentable::DocPage::Index::Programs.new.render($!registry);
            }
            when Kind::Routine {
                Perl6::Documentable::DocPage::Index::Routine.new.render($!registry);
            }
        }

        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $kind.gist,
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }

    method generate-subindex(Kind $kind, $category) {
        my %pod-to-render = do given $kind {
            when Kind::Routine {
                Perl6::Documentable::DocPage::SubIndex::Routine.new.render($!registry, $category);
            }
            when Kind::Type {
                Perl6::Documentable::DocPage::SubIndex::Type.new.render($!registry, $category);
            }
        }

        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $kind.gist,
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }


}