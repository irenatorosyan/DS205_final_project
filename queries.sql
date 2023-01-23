--1
Create View Menu_Description As
 WITH filtered_by_importance AS(
   select * from menu_items mi inner join menu_consists_ingredients mci on mi.product_id=menu_id inner join ingredients ing on mci.ing_id=ing.id where importance=True
 ) select menu_item_name, string_agg(ing_name, ', ') from filtered_by_importance group by menu_item_name;

 SELECT * FROM Menu_Description;


--2
select emp.emp_branch_id, count(*) as visits from Orders ord inner join Employees emp on ord.cashier_id=emp.id 
  group by emp_branch_id order by visits desc limit 1;


--3
Create View Least_ordered_menu_item As
Select menu_item_name From Menu_items Where product_id=(Select menu_item_id from (Select menu_item_id, Sum(quantity) as quantity From
(Select menu_item_id,menu_item_name,quantity From Order_Items i inner JOIN Menu_items mi on i.menu_item_id=mi.product_id)
as quantity
Group by menu_item_id
order by quantity
limit 1)as menu_item_id);

Select * from Least_ordered_menu_item;

--4
drop view if exists ingredients_spent;
drop view if exists ing_per_menu_item_weights;
 
create View ing_per_menu_item_weights AS
 select ing_id, (freq*weight ) as corresponding_weight from (select * from (select menu_item_id, sum(quantity) as freq  from order_items
 group by (menu_item_id)) as menu_item_freq
 inner join menu_consists_ingredients mci on menu_item_id=mci.menu_id) as ing_hist;
 
 
create View ingredients_spent AS
 select ing_id, sum(corresponding_weight) as total_weight from ing_per_menu_item_weights group by (ing_id);
 
select ii.ing_name, total_weight from ingredients_spent inner join ingredients ii on ii.id=ing_id;

--5
select ing_name, CEIL(total_weight/default_weight*raw_price) as money_spent from ingredients_spent inner join ingredients ii on ii.id=ing_id;

--6
drop view if exists ingredients_supplied;
create view ingredients_supplied as
 select ing_name, sum(supplied_weight) as total_sup_weight
 from (select ing_name, (default_weight  * amount) as supplied_weight from Ingredients ii inner join suppliers_supplies_warehouse ssw on ii.id = ssw.ing_id) as ing_sup_hist
 group by ing_name;

select ing_name, (total_sup_weight -total_weight) as current_amount  from ingredients_spent inner join ingredients ii on ii.id=ing_id
natural join ingredients_supplied;

--7
DROP VIEW if exists order_price;
CREATE VIEW order_price AS
 Select order_id,sum(price) as order_price From
 (Select order_id, price From
  (Select order_id,menu_item_name,(quantity*price) as price From
   (Select order_id , menu_item_name, quantity, price  From Order_Items i right JOIN Menu_items mi
    on i.menu_item_id=mi.product_id
    order by order_id)
   as price)
  as price)
  As foo
  group by order_id;
 
 
Select * From order_price;

--8
Create View most_productive_worker AS SELECT cashier_id, COUNT(*) AS number_of_orders
 FROM Orders JOIN Order_Items
 ON Orders.order_id = Order_Items.order_id
 GROUP BY Orders.order_id
 ORDER BY COUNT(*) DESC LIMIT 1;

select e.emp_name, e.emp_position, e.emp_branch_id from most_productive_worker inner join employees e on e.id=cashier_id;


--9
drop view if exists user_stats;
create view user_stats as
 select consumer_id, count(*), sum(price) as total_spent_price from (select * from (select * from orders
 inner join (Select order_id,sum(price) price From
 (Select order_id, price From
 (Select order_id,menu_item_name,(quantity*price) as price From
   (Select order_id , menu_item_name, quantity, price  From Order_Items i right JOIN Menu_items mi
   on i.menu_item_id=mi.product_id
   order by order_id)
   as price)
 as price)
 As foo
 group by order_id) as order_prices
 
 on orders.order_id=order_prices.order_id) as merged
 where order_timestamp > '2022-04-03'::timestamp) as final
 group by consumer_id;
 

select * from user_stats order by count desc limit 10;
select * from user_stats order by total_spent_price desc limit 10;



--10

drop view if exists most_purchased_item;
Create view most_purchased_item as
 Select menu_item_name From Menu_items Where product_id=(Select menu_item_id from (Select menu_item_id, Sum(quantity) as quantity From
 (Select menu_item_id,menu_item_name,quantity From Order_Items i inner JOIN Menu_items mi on i.menu_item_id=mi.product_id)
 as quantity
 Group by menu_item_id
 order by quantity desc
 limit 1)as menu_item_id);
 
select * from most_purchased_item;



