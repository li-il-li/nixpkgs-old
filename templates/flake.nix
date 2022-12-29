{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      trivial = {
        path = ./trivial;
        description = "A very basic flake";
      };


      rust = {
        path = ./rust;
        description = "Rust template";
      };

    };

    defaultTemplate = self.templates.trivial;

  };
}
