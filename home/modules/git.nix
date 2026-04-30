{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "cmichaelsd";
        email = "cmichaelsd@gmail.com";
      };
    };
  };
}
