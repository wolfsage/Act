package Act::Handler::User::Show;

use Act::Config;
use Act::Country;
use Act::Template::HTML;
use Act::User;

sub handler
{
    # retrieve user
    my $user = Act::User->new(user_id => $Request{path_info})
        or die "unknown user: $Request{path_info}";

    # process the template
    my $template = Act::Template::HTML->new();
    $template->variables(
        %$user,
        country => Act::Country::CountryName($user->{country}),
    );
    $template->process('user/show');
}

1;
__END__

=head1 NAME

Act::Handler::User::Show - show userinfo

=head1 DESCRIPTION

See F<DEVDOC> for a complete discussion on handlers.

=cut
