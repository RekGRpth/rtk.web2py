select      distinct
            provider as "Провайдер",
            direction as "Направление",
            house as "Дом"
from        pcfbdrsatta
where       date = '2021-04-08'
