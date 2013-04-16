package Scring::Wx::Pane::Search;

=head1 NAME

Scring::Wx::Pane::ExtendedSearch

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxVERTICAL wxID_ANY wxDefaultPosition wxDefaultSize wxCB_READONLY wxEXPAND wxBOTTOM wxALL wxLIST_FORMAT_LEFT wxHORIZONTAL wxRIGHT wxID_OK 
			wxCB_SORT);
use Wx::Event;
use Wx::ArtProvider qw( wxART_FIND );

use Scring::Util;
use Scring::Wx::Widget::LCBase;

use parent -norequire => qw( Wx::Panel );

use Object::Tiny qw( 
	listCtrl 
	comboBox 
	eintraege
	refresh
	
	aui
	frame
	
	dispatcher
	titleColumn
);

=head2 new

=cut

sub new {
	my ( $class, $parent, $auiManager ) = @_;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( $parent );

	$this->{frame} = $parent;
	$this->{aui} = $auiManager;
	$this->{dispatcher} = {
		'Bewertungsliste'          => 'loadBewertungsliste',
		'Einträge für Speicherort' => 'loadVideoBySpeicherortId',
	};
	
	
	$this->initialize;
	$this->loadComboBox;

	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$logger->trace( '---' );	
	
	my $S = $this->{S} = {};
	my $P = $this;
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Top}  = Wx::BoxSizer->new( wxHORIZONTAL );
	
	$this->{comboBox}  = Wx::ComboBox->new( $P, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, [], wxCB_READONLY | wxCB_SORT );
	$this->{refresh}    = Wx::BitmapButton->new( $P, wxID_ANY, Wx::ArtProvider::GetBitmap( wxART_FIND  ), wxDefaultPosition, Wx::wxSIZE( 29, 29 ) );
	$this->{listCtrl} = Scring::Wx::Widget::LCBase->new( $this, wxID_ANY );
	$this->{eintraege} = Wx::StaticText->new( $P, wxID_ANY, '' );
	
	$S->{Top}->Add( $this->comboBox, 1, wxRIGHT, 10 );
	$S->{Top}->Add( $this->refresh, 0 );
	$S->{Top}->Add( $this->eintraege, 0 );
	
	$S->{Rand}->Add( $S->{Top}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $this->listCtrl, 1, wxEXPAND );

	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	Wx::Event::EVT_LIST_ITEM_SELECTED( $this, $this->listCtrl, \&OnSelectedListCtrl );
	Wx::Event::EVT_COMBOBOX( $this, $this->comboBox, \&OnSelectionComboBox );
	Wx::Event::EVT_BUTTON( $this, $this->refresh, \&OnSelectionComboBox );
}

=head2 loadComboBox

=cut

sub loadComboBox {
	my $this = shift;
	
	$this->comboBox->Clear;
	$this->comboBox->Append( [ keys $this->dispatcher ] );
	$this->comboBox->SetSelection( 0 );
	
	1;
}

=head2 show( show )

=cut

sub show {
	my ( $this, $show ) = @_;
	
	$this->aui->showPane( $this, $show );
	
	1;
}

=head2 toggleShow

=cut

sub toggleShow {
	my $this = shift;
	
	if ( $this->aui->isPaneShown( $this ) ) {
		$logger->trace( 'hide' );
		$this->show( 0 );
		return 0;		
	} else {
		$this->show( 1 );
		return 1;
	}
}

=head2 OnSelectionComboBox

event

=cut

sub OnSelectionComboBox {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	my $method = $this->dispatcher->{ $this->comboBox->GetStringSelection };

	$this->$method;
}

=head2 OnSelectedListCtrl

event

=cut

sub OnSelectedListCtrl {
	my ( $this, $event ) = @_;
	
	$logger->trace( $event->GetIndex );
	
	$this->frame->loadVideo( id => $event->GetData );
}

=head2 loadView( viewName, \%search )

=cut

sub loadView {
	my ( $this, $view, $where ) = @_;
	
	$logger->trace( '---' );
	
	$this->listCtrl->ClearAll;
	
	my $rs = $schema->resultset( $view )->search( $where );
	
	my @columns = $rs->result_source->columns;
	my @lcColumns;
	
	for ( my $i = 0; $i < scalar @columns; $i++ ) {
		
		my $info = $rs->result_source->column_info( $columns[ $i ] );
		next if $info->{ignore};
		
		$this->{titleColumn} = 1 if $info->{titleColumn};
		$this->listCtrl->AppendColumn( $columns[ $i ], undef, $info->{proportion} );
		push @lcColumns, $columns[ $i ];
	}
	
	# force correct alignment
	$this->listCtrl->OnSize;
	
	my $i = 0;
	my $firstColumn = shift @lcColumns;
	while ( my $row = $rs->next ) {
		$this->listCtrl->InsertStringItem( $i, $row->get_column( $firstColumn ) );
		
		my $j = 1;
		for my $col ( @lcColumns ) {
			$this->listCtrl->SetItem( $i, $j++, $row->get_column( $col ) ); 
		}
		
		$i++;
	}
	
	1;
}

=head1 VIEW METHODEN FÜR DIE LC

=head2

=cut

=head2 loadBewertungsliste

=cut

sub loadBewertungsliste {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->listCtrl->ClearAll;
	$this->listCtrl->AppendColumn( 'Bewertung', undef, 1 );
	$this->listCtrl->AppendColumn( 'Titel', undef, 6 );
	$this->listCtrl->OnSize; # force correct alignment
	
	my $rs = $schema->resultset( 'Video' )->search( 
		{ Bewertung => { '!=' => '' } },
		{ 
			select => [ qw( id Titel Bewertung ) ],
			order_by => { -desc => 'Bewertung' },			
		}
		
	);
	
	my $i = 0;
	while ( my $row = $rs->next ) {
		$this->listCtrl->InsertStringItem( $i, $row->Bewertung );
		$this->listCtrl->SetItem( $i, 1, $row->Titel );
		$this->listCtrl->SetItemData( $i, $row->id );
		$i++;
	}
	
}

=head2 loadVideoBySpeicherortId( SpeicherortId )

=cut

sub loadVideoBySpeicherortId {
	my ( $this, $speicherortId ) = @_;
	
	return unless $speicherortId;
	
	$logger->trace( $speicherortId );
	
	$this->listCtrl->ClearAll;
	$this->listCtrl->AppendColumn( 'Titel', undef, 1 );
	$this->listCtrl->OnSize; # force correct alignment
	
	my $rs = $schema->resultset( 'Video' )->search(
		{ 'Speicherorte.Speicherort' => $speicherortId },
		{
			select => [ 'me.id', 'me.Titel' ],
			join => 'Speicherorte'
		}
	);
	
	my $i = 0;
	while ( my $row = $rs->next ) {
		$this->listCtrl->InsertStringItem( $i, $row->Titel );
		$this->listCtrl->SetItemData( $i, $row->id );
		$i++;
	}
}

1;
