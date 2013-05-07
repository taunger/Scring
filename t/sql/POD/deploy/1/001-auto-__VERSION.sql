=pod

=head1 DESCRIPTION

Schema

=head1 TABLES

=head2 dbix_class_deploymenthandler_versions

=head3 FIELDS

=head4 id

=over 4

=item * int

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 version

=over 4

=item * varchar(50)

=item * Nullable 'No' 

=back

=head4 ddl

=over 4

=item * text

=item * Nullable 'Yes' 

=back

=head4 upgrade_sql

=over 4

=item * text

=item * Nullable 'Yes' 

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = version

=back

=head1 PRODUCED BY

SQL::Translator::Producer::POD

=cut;
