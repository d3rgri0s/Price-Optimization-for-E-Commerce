select column_name,data_type
from information_schema.columns
where table_name = 'product_prices'

/* we selected all columns then from them we subtracted the rows in column price which are non_null so as to find the missing values*/

SELECT COUNT(*) - COUNT(category) AS missing_values 
FROM product_prices;

/* updating the null values with the avg of price column*/

update product_prices
set price = (select avg(price) from product_prices)
where price is null

/* if count is more than one for the specified columns return the record(s) as output
also noticed we use " " on some columns that used for columns with caps if not used postgres assumes all are lowercase*/

select uid, count(*) as duplicate_count
from product_prices
group by uid,asin,title,stars,reviews,price,category,"isBestSeller","boughtInLastMonth"
having count(*) > 1

/* ctid is a hidden column in postgresql like a sort of index so the syntax simply means delete all records which have the same ctid and leave the first one thus the min */
delete from product_prices
where ctid not in (
select min(ctid)
from product_prices
group by uid,asin,title,stars,reviews,price,category,"isBestSeller","boughtInLastMonth"
)

/*was to check if the prices are correct we found that min price was zero which is odd 
considering no item goes for the price of zero so we had to fill it with the avg of
the price column */

SELECT MIN(price) AS min_price, MAX(price) AS max_price
FROM product_prices;

select count(*) from product_prices where price = 0

update product_prices
set price = (select avg(price) from product_prices where price > 0)
where price= 0

/*checked for null values in the uid column and filled them with 'Unknown' */

SELECT COUNT(*) - COUNT(uid) FROM product_prices;
update product_prices
set uid = 'Unknown'
where uid is null

/*checked for null values in the asin column and filled them with 'Unknown' */

select count(*) - count(asin) from product_prices
update product_prices
set asin = 'Unknown'
where asin is null

/*checked for null values in the title column and filled them with 'Unknown' */

select count(*) - count(title) from product_prices
update product_prices
set title = 'Unknown' 
where title is null

/*checked for null values in the stars column and filled them with the avg of the 
column not including the null values
*/

select count(*) - count(stars) from product_prices
update product_prices
set stars = (select avg(stars) from product_prices where stars is not null)
where stars is null

/*checked for null values in the reviews column and filled them with the avg of the 
column not including the null values
*/

select count(*) - count(reviews) from product_prices
update product_prices
set reviews = (select avg(reviews) from product_prices where reviews is not null)
where reviews is null

select count(*) - count(price) from product_prices

/*checked for null values in the category column and filled them with 'Unknown' */

select count(*) - count(category) from product_prices
update product_prices
set category = 'Unknown'
where category is null

/*checked for null values in the "isBestSeller" column and filled them with 'False'
as datatype is boolean */

select count(*) - count("isBestSeller") from product_prices
update product_prices
set "isBestSeller" = 'False'
where "isBestSeller" is null

/*checked for null values in the "boughtInLastMonth" column and filled them with the avg of the 
column not including the null values */

select count(*) - count("boughtInLastMonth") from product_prices
update product_prices
set "boughtInLastMonth" = (select avg("boughtInLastMonth") from product_prices where "boughtInLastMonth" is not null)
where "boughtInLastMonth" is null

/* this was to merely change the records with datatype text to begin with caps */
update product_prices
set uid = initcap(uid)
update product_prices
set asin = initcap(asin)
update product_prices
set title = initcap(title)
update product_prices
set category = initcap(category)

select min(stars) as min_stars, max(stars) as max_stars
from product_prices



alter table product_prices
add column rating_category text

update product_prices
set rating_category = 
case
when stars < 3 then 'Low'
when stars between 3 and 4 then 'Medium'
else 'High'
end

alter table product_prices
add column price_category text

update product_prices
set price_category = 
case 
when price < 100 then 'Low'
when price between 100 and 1000 then 'Medium'
else 'High'
end


SELECT price_category, rating_category, COUNT(*) 
FROM product_prices
GROUP BY price_category, rating_category
ORDER BY price_category, rating_category;

select category, avg(price) as avg_price,
min(price) as min_price, max(price) as max_price
from product_prices
group by category
order by avg_price desc

select distinct on(category) category, title, price
from product_prices
order by category, price desc

select distinct category from product_prices
select count(distinct category) from product_prices


ALTER TABLE product_prices ADD COLUMN category_group TEXT;

UPDATE product_prices
SET category_group = CASE 
           WHEN "category" IN ('Security & Surveillance Equipment','Computers', 'Laptop Accessories', 'Computer Components', 'Tablets', 'Video Game Consoles & Accessories','Computers & Tablets', 'Smart Home: Home Entertainment','Video Projectors','Virtual Reality Hardware & Accessories','Electronic Components','Data Storage','Consoles & Accessories','Televisions & Video Products','Headphones & Earbuds','Pc Games & Accessories','Smart Home: Lawn And Garden','Tablet Replacement Parts','Smart Home: Other Solutions','Smart Home - Heating & Cooling','Smart Home: Plugs And Outlets','Online Video Game Services','Smart Home: Vacuums And Mops','Portable Audio & Video','Camera & Photo','Smart Home: Smart Locks And Entry','Smart Home: Wifi And Networking','Smart Home: Lighting','Mac Games & Accessories','Electrical Equipment','Gps & Navigation','Smart Home: Security Cameras And Systems','Computer Monitors','Smart Home: Voice Assistants And Hubs','Wearable Technology','Computer External Components') THEN 'Electronics & Computers'
           WHEN "category" IN ('Home Appliances', 'Lighting & Ceiling Fans', 'Bedding', 'Home Storage & Organization', 'Kitchen & Bath Fixtures','Wall Art','Light Bulbs','Vacuum Cleaners & Floor Care','Accessories & Supplies','Fabric Decorating','Furniture','Household Cleaning Supplies') THEN 'Home & Kitchen'
           WHEN "category" IN ('Makeup', 'Skin Care Products', 'Hair Care Products', 'Perfumes & Fragrances', 'Oral Care Products','Shaving & Hair Removal Products','Bath Products','Beauty & Personal Care') THEN 'Beauty & Personal Care'
           WHEN "category" IN ('Men''S Clothing','Men''s Clothing', 'Women''s Clothing', 'Kids'' Clothing', 'Men''s Shoes', 'Women''s Jewelry', 'Watches','Men''S Accessories','Women''S Accessories','Girls'' Clothing','Girls'' Jewelry','Women''S Handbags','Men''S Shoes','Boys'' Watches','Boys'' Clothing','Women''S Clothing','Girls'' Shoes','Girls'' Watches','Women''S Jewelry','Men''S Watches','Boys'' Jewelry') THEN 'Clothing & Accessories'
           WHEN "category" IN ('Video Games', 'Games & Accessories', 'Dolls & Accessories', 'Kids'' Play Tractors', 'Learning & Education Toys','Kids'' Play Cars & Race Cars','Kids'' Dress Up & Pretend Play','Novelty Toys & Amusements','Toys & Games','Building Toys','Toy Figures & Playsets','Sports & Outdoor Play Toys','Baby & Toddler Toys','Kids'' Play Boats','Kids'' Electronics','Kids'' Play Buses','Finger Toys','Kids'' Play Trains & Trams') THEN 'Toys & Games'
           WHEN "category" IN ('Safety & Security','Commercial Door Products','Automotive Tools & Equipment', 'Vehicle Electronics', 'Industrial Materials', 'Heavy Duty & Commercial Vehicle Equipment','Additive Manufacturing Products','Industrial Power & Hand Tools','Automotive Enthusiast Merchandise','Motorcycle & Powersports','Cutting Tools','Industrial & Scientific','Industrial Hardware','Fasteners','Automotive Tires & Wheels','Material Handling Products','Automotive Exterior Accessories','Rv Parts & Accessories','Filtration','Packaging & Shipping Supplies','Building Supplies','Welding & Soldering') THEN 'Automotive & Industrial'
           WHEN "category" IN ('Sports & Outdoors','Sports & Fitness', 'Outdoor Recreation', 'Sports Nutrition Products', 'Camping & Hiking Gear','Travel Duffel Bags','Luggage','Suitcases') THEN 'Sports & Outdoors'
           WHEN "category" IN ('Health & Household', 'Household Supplies', 'Pregnancy & Maternity Products', 'Janitorial & Sanitation Supplies','Sexual Wellness Products','Home Use Medical Supplies & Equipment','Health Care Products','Professional Dental Supplies','Vision Products','Wellness & Relaxation Products') THEN 'Health & Wellness'
           WHEN "category" IN ('Baby','Baby Care Products', 'Baby Strollers & Accessories', 'Baby Stationery', 'Baby Boys'' Clothing & Shoes', 'Baby Girls'' Clothing & Shoes', 'Kids'' Furniture','Baby & Child Care Products','Baby & Toddler Feeding Supplies','Baby Activity & Entertainment Products','Kids'' Party Supplies') THEN 'Baby & Kids'
           WHEN "category" IN ('Small Animal Supplies', 'Reptiles & Amphibian Supplies', 'Pet Bird Supplies', 'Horse Supplies') THEN 'Pet Supplies'
           when category in ('Party Decorations','Gift Wrapping Supplies') then 'Party supplies'
		   WHEN "category" IN ('Needlework Supplies','Knitting & Crochet Supplies','Office Electronics', 'Printers & Scanners', 'Learning & Education Toys', 'School Uniforms','Science Education Supplies','Printmaking Supplies','Lab & Scientific Products','Beading & Jewelry Making','Girls'' School Uniforms','Boys'' School Uniforms','Arts Crafts & Sewing Storage','Ebook Readers & Accessories') THEN 'Office & School Supplies'
           ELSE 'Other'
       END;


select category
from product_prices
where category_group = 'Other'

alter table product_prices
drop column category_group



select category_group,category
from product_prices

SELECT * FROM product_prices WHERE category_group = 'Clothing & Accessories';

SELECT category_group, COUNT(*) AS total_products
FROM product_prices
GROUP BY category_group
ORDER BY total_products DESC;

SELECT rating_category
FROM product_prices
GROUP BY category_group,rating_category

SELECT category_group, rating_category, COUNT(*) AS product_count
FROM product_prices
GROUP BY category_group, rating_category


