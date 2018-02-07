# frozen_string_literal: true
# converts input csv into people objects
require 'pry'
require 'american_date'

class Input
  def self.format(file)
    # CSV::Converters[:mytime] = lambda { |gender| gender.capitalizez!.scan(/^Female$|^F$|^Male$|^M$/) rescue gender}
    raise "Input cannot be empty" if CSV.read(file).empty?
    col_sep = determine_delimeter_and_headers(file)
    people = []

    CSV.foreach(file, col_sep: col_sep, skip_blanks: true) do |row|
      standardize_row(row, col_sep)
      row.map!(&:strip)
      p = Person.new(*row)
      p.gender = format_gender!(p.gender)
      p.birth_date = DateTime.parse(p.birth_date)
      people << p
    end
    people
  end

  private_class_method

  def self.format_gender!(gender)
    raise "Please use input with valid gender" if gender.strip.length > 6
    return "Female" if gender.capitalize.match(/^Female$|^F$/)
    "Male" if gender.capitalize.match(/^Male$|^M$/)
  end

  def self.standardize_row(row, delimiter)
    # all input has a middle name that's not expected in the output
    row.delete_at(2) unless delimiter == ","
    raise "Oops! Input has to have 5 or 6 columns" unless row.length == 5
    row[3], row[4] = row[4], row[3] unless delimiter == " "
  end

  def self.determine_delimeter_and_headers(file)
    File.foreach(file) do |line|
      words = line.strip.split("")
      case
      when words.empty?
        next
      when words.include?(",")
        return ","
      when words.include?("|")
        return "|"
      else
        return " "
      end
    end
  end
end

Person = Struct.new(:last_name, :first_name, :gender, :birth_date, :color)
