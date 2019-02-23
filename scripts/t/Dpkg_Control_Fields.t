#!/usr/bin/perl
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use strict;
use warnings;

use Test::More;
use Test::Dpkg qw(:paths);

BEGIN {
    plan tests => 2438;

    use_ok('Dpkg::Control::Types');
    use_ok('Dpkg::Control::FieldsCore');
}

#my $datadir = test_get_data_path();

my @src_dep_fields = qw(
    Build-Depends Build-Depends-Arch Build-Depends-Indep
    Build-Conflicts Build-Conflicts-Arch Build-Conflicts-Indep
);
my @bin_dep_normal_fields = qw(
    Pre-Depends Depends Recommends Suggests Enhances
);
my @bin_dep_union_fields = qw(
    Conflicts Breaks Replaces Provides Built-Using
);
my @bin_dep_fields = (@bin_dep_normal_fields, @bin_dep_union_fields);
my @src_checksums = qw(
    Checksums-Md5 Checksums-Sha1 Checksums-Sha256
);
my @bin_checksums = qw(
    MD5sum SHA1 SHA256
);
my @src_files = (@src_checksums, qw(Files));
my @bin_files = (qw(Filename Size), @bin_checksums);
my @vcs_fields = qw(
    Vcs-Browser Vcs-Arch Vcs-Bzr Vcs-Cvs Vcs-Darcs Vcs-Git Vcs-Hg Vcs-Mtn
    Vcs-Svn
);
my @test_fields = qw(
    Testsuite Testsuite-Triggers
);

my %fields = (
    CTRL_INFO_SRC() => {
        name => 'debian/control source stanza',
        unordered => 1,
        fields => [
            qw(Bugs Homepage Description Origin Maintainer Uploaders
               Priority Section Source Standards-Version),
            @test_fields, @vcs_fields, @src_dep_fields
        ],
    },
    CTRL_INFO_PKG() => {
        name => 'debian/control binary stanza',
        unordered => 1,
        fields => [
            qw(Architecture Build-Essential Build-Profiles Built-For-Profiles
               Description Essential Homepage
               Installer-Menu-Item Kernel-Version Multi-Arch
               Package Package-Type Priority Section Subarchitecture
               Tag Task), @bin_dep_fields
        ],
    },
    CTRL_PKG_SRC() => {
        name => '.dsc',
        fields => [
            qw(Format Source Binary Architecture Version Origin Maintainer
               Uploaders Homepage Description Standards-Version),
            @vcs_fields, @test_fields, @src_dep_fields,
            qw(Package-List),
            @src_files
        ],
    },
    CTRL_PKG_DEB() => {
        name => 'DEBIAN/control',
        fields => [
            qw(Package Package-Type Source Version Built-Using Kernel-Version
               Built-For-Profiles Auto-Built-Package Architecture
               Subarchitecture Installer-Menu-Item
               Build-Essential Essential Origin Bugs
               Maintainer Installed-Size), @bin_dep_fields,
            qw(Section Priority Multi-Arch Homepage Description Tag Task)
        ],
    },
    CTRL_INDEX_SRC() => {
        name => 'Sources',
        fields => [
            qw(Format Package Binary Architecture Version Priority Section
               Origin Maintainer Uploaders Homepage Description
               Standards-Version),
            @vcs_fields, @test_fields, @src_dep_fields,
            qw(Package-List Directory),
            @src_files
        ],
    },
    CTRL_INDEX_PKG() => {
        name => 'Packages',
        fields => [
            qw(Package Package-Type Source Version Built-Using Kernel-Version
               Built-For-Profiles Auto-Built-Package Architecture
               Subarchitecture Installer-Menu-Item
               Build-Essential Essential Origin Bugs
               Maintainer Installed-Size), @bin_dep_fields, @bin_files,
            qw(Section Priority Multi-Arch Homepage Description Tag Task)
        ],
    },
    CTRL_REPO_RELEASE() => {
        name => 'Release',
        fields => [
            qw(Origin Label Suite Codename Changelogs Date Valid-Until
               Architectures Components Description),
            @bin_checksums
        ],
    },
    CTRL_CHANGELOG() => {
        name => 'debian/changelog',
        fields => [
            qw(Source Binary-Only Version Distribution Urgency Maintainer
               Timestamp Date Closes Changes)
        ],
    },
    CTRL_COPYRIGHT_HEADER() => {
        name => 'debian/copyright Format stanza',
        fields => [
            qw(Format Upstream-Name Upstream-Contact Source Disclaimer Comment
               License Copyright)
        ],
    },
    CTRL_COPYRIGHT_FILES() => {
        name => 'debian/copyright Files stanza',
        fields => [
            qw(Files Copyright License Comment)
        ],
    },
    CTRL_COPYRIGHT_LICENSE() => {
        name => 'debian/copyright License stanza',
        fields => [
            qw(License Comment)
        ],
    },
    CTRL_TESTS() => {
        name => 'debian/tests/control',
        unordered => 1,
        fields => [
            qw(Classes Depends Features Restrictions Test-Command Tests
               Tests-Directory)
        ],
    },
    CTRL_FILE_BUILDINFO() => {
        name => '.buildinfo',
        fields => [
            qw(Format Source Binary Architecture Version Binary-Only-Changes),
            @src_checksums,
            qw(Build-Origin Build-Architecture Build-Kernel-Version
               Build-Date Build-Path Build-Tainted-By
               Installed-Build-Depends Environment)
        ],
    },
    CTRL_FILE_CHANGES() => {
        name => '.changes',
        fields => [
            qw(Format Date Source Binary Binary-Only Built-For-Profiles
               Architecture Version Distribution Urgency Maintainer
               Changed-By Description Closes Changes),
            @src_files
        ],
    },
    CTRL_FILE_VENDOR() => {
        name => 'dpkg origin',
        unordered => 1,
        fields => [
            qw(Bugs Parent Vendor Vendor-Url)
        ],
    },
    CTRL_FILE_STATUS() => {
        name => 'dpkg status',
        fields => [
            qw(Package Essential Status Priority Section Installed-Size
               Origin Maintainer Bugs Architecture Multi-Arch Source
               Version Config-Version
               Replaces Provides Depends Pre-Depends
               Recommends Suggests Breaks Conflicts Enhances
               Conffiles Description Triggers-Pending Triggers-Awaited
               Auto-Built-Package Build-Essential Built-For-Profiles
               Built-Using Homepage Installer-Menu-Item Kernel-Version
               Package-Type Subarchitecture Tag Task)
        ],
    },
);

is_deeply([ field_list_src_dep() ],
          [ @src_dep_fields ],
          'List of build dependencies');
is_deeply([ field_list_pkg_dep() ],
          [ @bin_dep_fields ],
          'List of build dependencies');

is(field_capitalize('invented-field'), 'Invented-Field',
   'Field Invented-Field capitalization');
ok(!field_is_official('invented-field'),
   'Field Invented-Field is not official');

my %known_fields;
foreach my $type (sort keys %fields) {
    if (not $fields{$type}->{unordered}) {
        is_deeply([ field_ordered_list($type) ], $fields{$type}->{fields},
                  "List of $fields{$type}->{name} fields");
    }

    foreach my $field (@{$fields{$type}->{fields}}) {
        $known_fields{$field} = 1;
    }
}

foreach my $field (sort keys %known_fields) {
    is(field_capitalize($field), $field, "Field $field capitalization");
    is(field_capitalize(lc $field), $field, "Field lc($field) capitalization");
    is(field_capitalize(uc $field), $field, "Field uc($field) capitalization");

    ok(field_is_official($field), "Field $field is official");
    ok(field_is_official(lc $field), "Field lc($field) is official");
    ok(field_is_official(uc $field), "Field uc($field) is official");
}

foreach my $type (sort keys %fields) {
    my %allowed_fields = map { $_ => 1 } @{$fields{$type}->{fields}};

    foreach my $field (sort keys %known_fields) {
        if ($allowed_fields{$field}) {
            ok(field_is_allowed_in($field, $type),
               "Field $field allowed for type $type");
        } else {
            ok(!field_is_allowed_in($field, $type),
               "Field $field not allowed for type $type");
        }
    }
}
