package SelectedExportLog::Plugin;
use strict;
use warnings;

use MT::Util qw( format_ts ts2epoch epoch2ts offset_time dirify );

sub _export_log {
    my $app       = shift;
    my $user      = $app->user;
    my $blog      = $app->blog;
    my $blog_view = $blog ? 1 : 0;
    my $blog_ids;

    return $app->trans_error( 'Permission denied.' ) unless _condition_export_log();

    $app->validate_magic() or return;
    local $| = 1;
    my $enc = $app->config('ExportEncoding');
    $enc = $app->config('LogExportEncoding') if ( !$enc );
    $enc = $app->charset || $app->config->PublishCharset unless $enc;
    my @ids;
    if ( $app->param( 'all_selected' ) ) {
        $app->setup_filtered_ids;
    } else {
        @ids = $app->param( 'id' );
    }
    my $iter = MT->model( 'log' )->load_iter( { id => \@ids } );
    my $log_class  = $app->model('log');
    my $blog_class = $app->model('blog');
    my %blogs;
    my $file = '';
    $file = dirify( $blog->name ) . '-' if $blog;
    $file = "Blog-" . $blog->id . '-'   if $file eq '-';
    my @ts = gmtime(time);
    my $ts = sprintf "%04d-%02d-%02d-%02d-%02d-%02d", $ts[5] + 1900,
        $ts[4] + 1,
        @ts[ 3, 2, 1, 0 ];
    $file .= "log_$ts.csv";
    $app->{no_print_body} = 1;
    $app->set_header( "Content-Disposition" => "attachment; filename=$file" );
    $app->send_http_header(
        $enc
        ? "text/csv; charset=$enc"
        : 'text/csv'
    );
    my $csv = "id,timestamp,ip,weblog,message,metadata\n";
    while ( my $log = $iter->() ) {
        # columns:
        # date, ip address, weblog, log message
        my @col;
        push @col, $log->id;
        my $ts = $log->created_on;
        if ($blog_view) {
            push @col,
                format_ts(
                "%Y-%m-%d %H:%M:%S",
                epoch2ts( $blog, ts2epoch( undef, $ts, 1 ) ),
                $blog,
                $app->user ? $app->user->preferred_language : undef
                );
        }
        else {
            push @col,
                format_ts(
                "%Y-%m-%d %H:%M:%S",
                epoch2ts(
                    undef, offset_time( ts2epoch( undef, $log->created_on ) )
                ),
                undef,
                $app->user ? $app->user->preferred_language : undef
                );
        }
        push @col, $log->ip;
        my $blog;
        if ( $log->blog_id ) {
            $blog = $blogs{ $log->blog_id }
                ||= $blog_class->load( $log->blog_id );
        }
        if ($blog) {
            my $name = $blog->name;
            $name =~ s/"/\\"/gs;
            $name =~ s/[\r\n]+/ /gs;
            push @col, '"' . $name . '"';
        }
        else {
            push @col, '';
        }
        my $msg = $log->message;
        $msg =~ s/"/\\"/gs;
        $msg =~ s/[\r\n]+/ /gs;
        push @col, '"' . $msg . '"';
        my $metadata = $log->metadata;
        $metadata =~ s/"/\\"/gs;
        $metadata =~ s/[\r\n]+/ /gs;
        push @col, '"' . $metadata . '"';
        $csv .= ( join ',', @col ) . "\n";
        $app->print( Encode::encode( $enc, $csv ) );
        $csv = '';
    }
}

sub _condition_export_log {
    my $app       = MT->instance();
    my $user      = $app->user;
    my $blog      = $app->blog;
    my $blog_view = $blog ? 1 : 0;
    my $blog_ids;
PERMCHECK: {
        if ($blog_view) {
            push @$blog_ids, $blog->id
                if $user->permissions( $blog->id )->can_do('export_blog_log');
            if ( !$blog->is_blog ) {
                foreach my $b ( @{ $blog->blogs } ) {
                    push @$blog_ids, $b->id
                        if $user->permissions( $b->id )
                        ->can_do('export_blog_log');
                }
            }
            last PERMCHECK if $blog_ids;
        }
        last PERMCHECK
            if $app->can_do('export_system_log');
        last PERMCHECK
            if $user->can_do( 'export_blog_log', at_least_one => 1 );
        return 0;
    }
    return 1;
}

sub _message_export_log {
    my $plugin = MT->component( 'SelectedExportLog' );
    return $plugin->translate( 'Download' );
}

1;
