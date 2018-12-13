require_relative '../models/address_book'
require 'pry'


class MenuController
  attr_reader :address_book

  def initialize
    @address_book = AddressBook.first
  end

  def main_menu
    puts "#{@address_book.name} Address Book Selected\n#{@address_book.entries.count} entries"
    puts "0 - Switch AddressBook"
    puts "1 - View all entries"
    puts "2 - View entries by batch"
    puts "3 - Create an entry"
    puts "4 - Search for an entry"
    puts "5 - Import entries from a CSV"
    puts "6 - Update Multiple Records"
    puts "7 - Destroy"
    puts "8 - Exit"
    print "Enter your selection: "

    selection = gets.to_i

    case selection
      when 0
        system "clear"
        select_address_book_menu
        main_menu
      when 1
        system "clear"
        view_all_entries
        main_menu
      when 2
        system "clear"
        batch_menu
        main_menu
      when 3
        system "clear"
        create_entry
        main_menu
      when 4
        system "clear"
        search_entries_type
        main_menu
      when 5
        system "clear"
        read_csv
        main_menu
      when 6
        system "clear"
        batch_update_menu
        main_menu
      when 7
        system "clear"
        delete_menu
        main_menu
      when 8
        puts "Good-bye!"
        exit(0)
      else
        system "clear"
        puts "Sorry, that is not a valid input"
        main_menu
    end
  end

  def select_address_book_menu
    puts "Select an Address Book:"
    AddressBook.all.each_with_index do |address_book, index|
      puts "#{index} - #{address_book.name}"
    end

    index = gets.chomp.to_i

    @address_book = AddressBook.find(index + 1)
    system "clear"
    return if @address_book
    puts "Please select a valid index"
    select_address_book_menu
  end

  def view_all_entries
    @address_book.entries.sort {|a,b| a.name <=> b.name}.each do |entry|
      system "clear"
      puts @address_book.entries.to_s
      entry_submenu(entry)
    end

    system "clear"
    puts "End of entries"
  end

  def batch_menu
    puts "Batch Menu - #{@address_book.entries.count} entries"
    puts "1 - View each entry"
    puts "2 - View each in batch"
    puts "4 - Exit"
    print "Enter your selection: "

    selection = gets.to_i

    case selection
      when 1
        system "clear"
        view_each_contact
        main_menu
      when 2
        system "clear"
        @address_book.entries.sort {|a,b| a.name <=> b.name}.find_in_batches do |records|
          view_contacts_in_batches(records)
        end
        main_menu
      when 4
        puts "Good-bye!"
        exit(0)
      else
        system "clear"
        puts "Sorry, that is not a valid input"
        main_menu
    end
  end

  def delete_menu
    puts "Delete Menu - #{@address_book.entries.count} entries"
    puts "1 - Destroy by id"
    puts "2 - Destroy all by type"
    puts "4 - Exit"
    print "Enter your selection: "

    selection = gets.to_i

    case selection
      when 1
        begin
          system "clear"
          puts "Input ID to Delete: \n (i.e. '1' or '1,2,3')"
          entry_id_to_delete = gets.chomp
          Entry.destroy(entry_id_to_delete)
        ensure
          main_menu
        end
      when 2
        begin
          system "clear"
          puts "Input type to Delete: \n (i.e. 'phone_number')"
          entry_type_to_delete = gets.chomp
          system "clear"
          puts "Input value to Delete: \n (i.e. '999-999-9999')"
          entry_value_to_delete = gets.chomp
          Entry.destroy_all("#{entry_type_to_delete} = '#{entry_value_to_delete}'")
        ensure
          main_menu
        end
      when 4
        puts "Good-bye!"
        exit(0)
      else
        system "clear"
        puts "Sorry, that is not a valid input"
        main_menu
    end
  end

  def view_each_contact
    @address_book.entries.sort {|a,b| a.name <=> b.name}.find_each
    puts "n - next entry"
    puts "d - delete entry"
    puts "e - edit this entry"
    puts "m - return to main menu"

    selection = gets.chomp

    case selection
      when "n"
      when "d"
        delete_entry(entry)
      when "e"
        edit_entry(entry)
        entry_submenu(entry)
      when "m"
        system "clear"
        main_menu
      else
        system "clear"
        puts "#{selection} is not a valid input"
        entry_submenu(entry)
    end
    
  end
  
  def view_contacts_in_batches(records)
    records.each do |record|
      puts record
      puts "n - next entry"
      puts "d - delete entry"
      puts "e - edit this entry"
      puts "m - return to main menu"

      selection = gets.chomp

      case selection
        when "n"
          next
        when "d"
          delete_entry(entry)
        when "e"
          edit_entry(entry)
          entry_submenu(entry)
        when "m"
          system "clear"
          main_menu
        else
          system "clear"
          puts "#{selection} is not a valid input"
          entry_submenu(entry)
      end
    end
  end

  def batch_update_menu
    system "clear"
    puts "enter string of ids to update \n (i.e. '1,2,3')"
    ids = gets.chomp.split(",").map(&:to_i)
    batch_update(ids)
  end

  def batch_update(ids)    
    Entry.find(ids).each do |user|
      user_updates = {}
      puts "name: #{user.name}"
      puts "phone number: #{user.phone_number}"
      puts "email: #{user.email}"
      puts "New Name: "
      user_updates[:name] = gets.chomp
      puts "New Phone Number: "
      user_updates[:phone_number] = gets.chomp
      puts "New Email: "
      user_updates[:email] = gets.chomp
      updates.merge!(user.id => user_updates)
    end
    Entry.update(updates.keys, updates.values)
  end

  def create_entry
    system "clear"
    puts "New AddressBloc Entry"
    print "Name: "
    name = gets.chomp
    print "Phone number: "
    phone = gets.chomp
    print "Email: "
    email = gets.chomp

    @address_book.add_entry(name, phone, email)

    system "clear"
    puts "New entry created"
  end

  def search_entries_type
    puts "#{@address_book.name} Address Book - #{@address_book.entries.count} entries"
    puts "1 - Name"
    puts "2 - Phone"
    puts "3 - Email"
    puts "4 - Other"
    print "Enter your selection: "

    selection = gets.to_i

    case selection
      when 1
        system "clear"
        search_entries_by_name
        main_menu
      when 2
        system "clear"
        search_entries_by_phone_number
        main_menu
      when 3
        system "clear"
        search_entries_by_email
        main_menu
      when 4
        system "clear"
        search_entries_by_other
        main_menu
      when 5
        system "clear"
        main_menu
      else
        system "clear"
        puts "Sorry, that is not a valid input"
        search_entries_type
    end
  end

  def search_entries_by_name
    print "Search by name: "
    name = gets.chomp
    match = @address_book.find_entry(name)
    system "clear"
    if match
      puts match.to_s
      search_submenu(match)
    else
      puts "No match found for #{name}"
    end
  end

  def search_entries_by_phone_number
    print "Search by phone number: "
    number = gets.chomp
    match = @address_book.entries.find_by_phone_number(number)
    system "clear"
    if match
      puts match.to_s
      search_submenu(match)
    else
      puts "No match found for #{number}"
    end
  end

  def search_entries_by_email
    print "Search by email: "
    email = gets.chomp
    match = @address_book.entries.find_by_email(email)
    system "clear"
    if match
      puts match.to_s
      search_submenu(match)
    else
      puts "No match found for #{email}"
    end
  end

  def search_entries_by_other
    print "Enter search type: "
    sub_menu_for_search_entries_by_other(gets.chomp)
    system "clear"
  end

  def sub_menu_for_search_entries_by_other(attribute)
    print "Search by #{attribute}: "
    value = gets.chomp
    match = @address_book.entries.find_by(attribute, value)
    system "clear"
    if match
      puts match.to_s
      search_submenu(match)
    else
      puts "No match found for #{value}"
    end
  end

  def read_csv
    print "Enter CSV file to import: "
    file_name = gets.chomp

    if file_name.empty?
      system "clear"
      puts "No CSV file read"
      main_menu
    end

    begin
      entry_count = @address_book.import_from_csv(file_name).count
      system "clear"
      puts "#{entry_count} new entries added from #{file_name}"
    rescue
      puts "#{file_name} is not a valid CSV file, please enter the name of a valid CSV file"
      read_csv
    end
  end

  def entry_submenu(entry)
    puts "n - next entry"
    puts "d - delete entry"
    puts "e - edit this entry"
    puts "m - return to main menu"
    puts "s - update email"

    selection = gets.chomp

    case selection
      when "n"
      when "d"
        delete_entry(entry)
      when "e"
        edit_entry(entry)
        entry_submenu(entry)
      when "s"
        quick_email_edit_entry(entry)
        entry_submenu(entry)
      when "m"
        system "clear"
        main_menu
      else
        system "clear"
        puts "#{selection} is not a valid input"
        entry_submenu(entry)
    end
  end

  def delete_entry(entry)
    entry.destroy
    puts "#{entry.name} has been deleted"
  end

  def edit_entry(entry)
    updates = {}
    print "Updated name: "
    name = gets.chomp
    updates[:name] = name unless name.empty?
    print "Updated phone number: "
    phone_number = gets.chomp
    updates[:phone_number] = phone_number unless phone_number.empty?
    print "Updated email: "
    email = gets.chomp
    updates[:email] = email unless email.empty?

    entry.update_by(updates)
    system "clear"
    puts "Updated entry:"
    puts Entry.find(entry.id)
  end
  
  def quick_email_edit_entry(entry)
    print "New Email:"
    value = gets.chomp
    Entry.update_email(entry.id, value)
    system "clear"
    puts "Updated entry:"
    puts Entry.find(entry.id)
  end

  def search_submenu(entry)
    puts "\nd - delete entry"
    puts "e - edit this entry"
    puts "m - return to main menu"
    puts "s - update email"
    selection = gets.chomp

    case selection
      when "d"
        system "clear"
        delete_entry(entry)
        main_menu
      when "e"
        edit_entry(entry)
        system "clear"
        main_menu
      when "m"
        system "clear"
        main_menu
      when "s"
        quick_email_edit_entry(entry)
        entry_submenu(entry)
      else
        system "clear"
        puts "#{selection} is not a valid input"
        puts @address_book.entries.to_s
        search_submenu(entry)
    end
  end
end

