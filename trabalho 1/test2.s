tipo:
   integer = inteiro

função:
   fatorial( valor integer:x ) =
      local:
         fat: integer := 1

      ação:
         enquanto x > 1 faça
            fat := fat * x;
            x := x - 1
         fenquanto;
         imprime(fat)

ação:
   fatorial(18)
