RSpec.describe 'Advent of Code' do
  current_day = (Time.now.year == 2024 && Time.now.month == 12) ? Time.now.day : 0
  stop_at = [current_day, 25].min

  (1..stop_at).each do |day|
    context "Day #{day}" do
      (1..2).each do |part|
        context "Part #{part}" do
          example_input_path = "spec/fixtures/day#{day}/part#{part}/example.input"
          example_output_path = "spec/fixtures/day#{day}/part#{part}/example.output"
          actual_input_path = "spec/fixtures/day#{day}/part#{part}/actual.input"
          actual_output_path = "spec/fixtures/day#{day}/part#{part}/actual.output"
          script_path = "solutions/day#{day}/part#{part}.rb"

          script_exists = File.exist?(script_path)
          example_files_exist = File.exist?(example_input_path) &&
            File.exist?(example_output_path)
          actual_files_exist = File.exist?(actual_input_path) &&
            File.exist?(actual_output_path)

          if script_exists && example_files_exist
            it "solves the example" do
              solution = `ruby #{script_path} #{example_input_path}`.strip
              expected = File.read(example_output_path).strip
              expect(solution).to eq(expected)
            end
          else
            pending "No examples for this day yet"
          end

          if script_exists && actual_files_exist
            it "solves the problem" do
              solution = `ruby #{script_path} #{actual_input_path}`.strip
              expected = File.read(actual_output_path).strip
              expect(solution).to eq(expected)
            end
          else
            pending "No input for this day yet"
          end
        end
      end
    end
  end
end
