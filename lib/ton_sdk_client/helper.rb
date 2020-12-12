module TonSdk
  class Helper
    def self.sym_to_capitalized_camel_case_str(symb)
      symb.to_s.split('_').collect(&:capitalize).join
    end

    def self.capitalized_case_str_to_snake_case_sym(str)
        str.split(/(?=[A-Z])/).map(&:downcase).join("_").to_sym
    end
  end
end