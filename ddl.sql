drop table if exists Order_Items;
drop table if exists Orders;
drop table if exists Menu_Consists_Ingredients;
drop table if exists suppliers_supplies_warehouse;
drop table if exists Suppliers;
drop table if exists Employees;
drop table if exists Branches;
drop table if exists warehouse_stores_ingredients;
drop table if exists Ingredients;
drop table if exists Warehouse;
drop table if exists Users cascade;
drop table if exists Menu_items;

drop table if exists Users cascade;
create table Users
(
    id	integer	primary key,
    contacts Varchar(32) not null unique
);

drop table if exists Warehouse;
create table Warehouse
(
    warehouse_id integer primary key,
	adress Varchar(64) not null
);

drop table if exists Branches cascade;
create table Branches
(
    id	Integer primary key,
	warehouse_id integer references warehouse(warehouse_id),
	area Numeric(5,2) not null check (area > 0),
    adress Varchar(64) not null,
	price Integer not null check (price > 0)
);


drop table if exists Employees;
create table Employees
(
    id	integer	not null primary key,
	emp_name Varchar(32) not null,
	emp_position Varchar(32) not null,
	emp_branch_id Integer references branches(id),
	salary Numeric(7,2) not null check (salary > 0),
	onboarding Timestamp
);

drop table if exists Ingredients;
create table Ingredients
(
    id	integer	not null PRIMARY KEY,
	ing_name Varchar(64) not null,
	raw_price Integer check (raw_price > 0),
	default_weight Integer check (default_weight > 0 ),
	weekly_amount Integer check (weekly_amount >= 0 )

);

drop table if exists Suppliers;
create table Suppliers
(
    id	integer	not null PRIMARY KEY,
	sup_name Varchar(32) not null,
	contacts Varchar(32) not null unique

);

drop table if exists suppliers_supplies_warehouse;
create table suppliers_supplies_warehouse
(
	supplier_id	integer	references suppliers(id),
    warehouse_id integer references warehouse(warehouse_id),
	ing_id	integer	references Ingredients(id),
	amount integer not null,
  supplied_date DATE default CURRENT_DATE,
	constraint ssw_composite_key primary key(supplier_id, warehouse_id, ing_id)
);

drop table if exists warehouse_stores_ingredients;
create table warehouse_stores_ingredients
(
	warehouse_id integer references warehouse(warehouse_id),
	ing_id	integer	references Ingredients(id),
	capacity integer not null,
	constraint warehouse_composite_key primary key(warehouse_id, ing_id)
);

drop table if exists Menu_items;
create table Menu_items
(
    product_id	integer	not null primary key,
	menu_item_name Varchar(32) not null,
	price Numeric(6,2) not null check (price > 0)
);

drop table if exists Menu_Consists_Ingredients;
create table Menu_Consists_Ingredients
(
	ing_id	integer	references Ingredients(id),
    menu_id	integer	references Menu_items(product_id),
	weight Numeric(6,2) not null check (weight > 0),
	importance bool default false,
	constraint constists_pk primary key (ing_id, menu_id)
);


drop table if exists Orders;
create table Orders
(
	order_id integer primary key,
    cashier_id integer references Employees(id),
	consumer_id integer references Users(id),
	branch_id integer references branches(id),
	order_timestamp Timestamp default current_timestamp
);

drop table if exists Order_Items;
create table Order_Items
(
	menu_item_id integer references Menu_items(product_id),
	order_id integer references Orders(order_id),
	quantity integer not null check (quantity > 0),
	constraint order_item_pk primary key (menu_item_id, order_id)
);