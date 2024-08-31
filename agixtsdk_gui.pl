#!/usr/bin/perl

use strict;
use warnings;

use Prima qw(Application);
use Prima::VB::Dialog;
use Prima::Edit;
use Prima::Button;
use Prima::Label;
use Prima::ListBox;
use Prima::ScrollBar;

use AGiXTSDK;  # Assuming AGiXTSDK is in the same directory or in your Perl library path

my $app = Prima::Application->create(
    title => 'AGiXT GUI',
    width => 800,
    height => 600,
);

# --- Main Window Layout ---

my $main_dialog = Prima::VB::Dialog->create(
    $app,
    title => 'AGiXT Control Panel',
    left => 10, 
    top => 10,
);

# --- API Key Input ---

my $api_key_label = Prima::Label-> create(
    $main_dialog,
    text => 'API Key:',
    left => 10,
    top => 10,
);

my $api_key_edit = Prima::Edit->create(
    $main_dialog,
    text => '',  # Initial API key
    left => 80,
    top => 10,
    width => 300,
);

# --- Agent Selection ---

my $agent_label = Prima::Label->create(
    $main_dialog,
    text => 'Agent:',
    left => 10,
    top => 40,
);

my $agent_listbox = Prima::ListBox->create(
    $main_dialog,
    items => [],  # Will be populated with agent names
    left => 80,
    top => 40,
    width => 200,
);

# --- Conversation List ---

my $conversation_label = Prima::Label->create(
    $main_dialog,
    text => 'Conversations:',
    left => 300,
    top => 40,
);

my $conversation_listbox = Prima::ListBox->create(
    $main_dialog,
    items => [],  # Will be populated with conversation names
    left => 400,
    top => 40,
    width => 200,
);

# --- User Input ---

my $input_label = Prima::Label->create(
    $main_dialog,
    text => 'Input:',
    left => 10,
    top => 80,
);

my $user_input_edit = Prima::Edit->create(
    $main_dialog,
    text => '',
    left => 80,
    top => 80,
    width => 520,
);

# --- Output Area ---

my $output_label = Prima::Label->create(
    $main_dialog,
    text => 'Output:',
    left => 10,
    top => 120,
);

my $output_edit = Prima::Edit->create(
    $main_dialog,
    text => '',
    left => 80,
    top => 120,
    width => 520,
    height => 300,
    vscroll => 1, # Add vertical scrollbar
    readonly => 1,
);

# --- Action Buttons ---

my $send_button = Prima::Button->create(
    $main_dialog,
    text => 'Send',
    left => 80,
    top => 430,
    onClick => sub {
        send_input();
    },
);

my $clear_button = Prima::Button->create(
    $main_dialog,
    text => 'Clear Output',
    left => 180,
    top => 430,
    onClick => sub {
        $output_edit->text('');
    },
);

# --- AGiXT SDK Initialization ---

my $agixtsdk;

sub initialize_sdk {
    my $api_key = $api_key_edit->text;
    $agixtsdk = AGiXTSDK->new(api_key => $api_key);
    populate_agent_list();
}

sub populate_agent_list {
    my @agents = $agixtsdk->get_agents();
    $agent_listbox->items(@agents);
}

sub populate_conversation_list {
    my $selected_agent = $agent_listbox->selected;
    my @conversations = $agixtsdk->get_conversations(agent_name => $selected_agent);
    $conversation_listbox->items(@conversations);
}

# --- Sending User Input ---

sub send_input {
    my $selected_agent = $agent_listbox->selected;
    my $selected_conversation = $conversation_listbox->selected;
    my $user_input = $user_input_edit->text;

    if (not defined $selected_agent or $selected_agent eq '') {
        $output_edit->text("Please select an agent.");
        return;
    }

    # ... (Call appropriate AGiXTSDK methods here)
    # For example, to use the 'chat' method:
    my $response = $agixtsdk->chat(
        agent_name => $selected_agent,
        user_input => $user_input,
        conversation => $selected_conversation,
    );

    # Append the response to the output area
    $output_edit->text($output_edit->text . "\nAgent: " . $response);
}

# --- Event Handling ---

$api_key_edit->onActivate => sub { initialize_sdk() };
$agent_listbox->onSelect => sub { populate_conversation_list() };

# --- Run the Application ---

$main_dialog->show;
$app->run();