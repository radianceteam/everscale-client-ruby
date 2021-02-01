module TonSdk
  class Helper

    # converts a symbol which may contain _, into a capital-case string
    # :aaa_bbb_ccc -> AaaBbbCcc
    def self.sym_to_capitalized_case_str(symb)
      symb.to_s.split('_').collect(&:capitalize).join
    end


    # converts a string with capitalized letters
    # into a symbol
    # AaaBbbCcc --> :aaa_bbb_ccc
    def self.capitalized_case_str_to_snake_case_sym(str)
        str.split(/(?=[A-Z])/).map(&:downcase).join("_").to_sym
    end
  end
end