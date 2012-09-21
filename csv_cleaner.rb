#!/usr/bin/env ruby

# Super Simple CSV Cleaner
# Copyright 2012 Rietta Inc.
# Licensed under terms of BSD License.

require 'csv'
require 'optparse'

#
# Process the CSV input using default settings and trim every cell.
#
def clean_csv(input, output)
  #raise "TODO: Implement CSV cleaner function!"
  raise "Expect an input file, but didn't receive one."   unless nil != input && input.respond_to?(:read)
  raise "Expect an output file, but didn't receive one."  unless nil != output && output.respond_to?(:write)
  
  CSV.foreach(input) do |row|
    # use row here...
    #puts row.inspect
    
    if row && row.kind_of?(Array)
      # If this row is an array, clean it!
      clean_row = Array.new
      row.each do |cell|
        # Remove all whitespace in the cell
        clean_row.push(cell.to_s.strip) 
      end # each

      output.write clean_row.to_csv
    end # parsed row
    
  end # foreach CSV row

end # clean_csv


########################################################################
# Command Line Options
########################################################################

options = {:input_file => nil, :output_file => nil}

option_parser = OptionParser.new do |opts|
  opts.on('-f INPUT_FILE', '--file INPUT_FILE') do |input_file|
     options[:input_file] = input_file
  end
  
  opts.on('-o OUTPUT_FILE', '--output-file OUTPUT_FILE') do |output_file|
      if output_file && output_file != '-'
        options[:output_file] = output_file
      end
  end
end

option_parser.parse!

#
# Also supports the filename being specified on the command line bare
#

if nil == options[:input_file] && ARGV.length > 0
  possible_file_to_read = ARGV.pop
  if File::exists?(possible_file_to_read)
    options[:input_file] = possible_file_to_read
  end
end

#
# See if the input and output file are ready
#


if options[:input_file].nil?
  # Read from standard in!
   #input_file = STDIN
  
  STDERR.puts "-- Nothing to do. No input file was specified.  Run csv_cleaner --help for usage."
  input_file = nil
  exit 1;
 
elsif "-" == options[:input_file]
  raise "-- Standard in input is not yet implemented."
  #input_file = STDIN
elsif options[:input_file]  && File::exists?(options[:input_file])
  input_file = File.new(options[:input_file], 'r')
else
  raise "I don't know what to do with the input file you specified."
end

if options[:output_file].nil?
  output_file = STDOUT
elsif "-" == options[:output_file]
  output_file = STDOUT
elsif options[:output_file]
  output_file = File.new(options[:output_file], 'w')
else
  raise "I don't know what to do with the output file you specified."
end

#
# Queue up the work!
#

clean_csv(input_file, output_file) if output_file && input_file

# Close out the files
output_file.close if output_file
input_file.close if input_file

