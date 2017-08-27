{ config, pkgs, ... }:

{
  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  users.users.tobias.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPRLFjQRecCfkmpRJVwNIsua/+fyHQsDfSrW5UijXkrZjygBlMMu2le6tQihrp/RYZUoh0bV3zEpAiWWkvMWrt7C1nPcL8LwaJFJ5yjHwZi3ubMUYZXoNg2/GdY6GQXWDL0rZmxf1wsaRnmCLpDbH/kmbVaRNq0M4tg6jvGOgBTmXV/gHmCzlMwo5EJguOmKUn5rlPIjoe7HInH1osJGEhYaxPwJxFpmJO2E8h1OzntH66WXbqh5NNjz98X5unl47UXyOataYMSwf/ef6Xkhr/ywyFiBIW89AENC5sQIbOhCLB8Wnx94rpMDVrwieV+CZAJ3H19x/lN2SMDMWo/sdPj8eKF8bS2V5PjrUay7/PnI2TjgjTtC54z5F9VBmcGc2gYnfDqSUuzSOJMWtR1ERbVklK45jgWqd6VBzDzzEfRXsI/ewPRMD1AK/e/lThh//4E/87LOKbXrvbDSsrXArXeE/9GPETRMwXT3jHm/UZm8KelfRgmWeAfEM0dlYPal0X2dCV9hpTxXRLRaV+U6kgenxS770642qs7eY0c1WMat7obZp7+kZISMALlHIGVW4EfkrJnlnlGjMsBjYWpoRuiHALZ39ern/Zh0qBlX+1ev2Xkj1QGHlEsrVQpTRt5ViGbYO7ejBRqgXxjhWQ6KtUA2dXUUjLtdCXpWmx7/8qHw== tobias@Tobias-Laptop"
  ];
}
