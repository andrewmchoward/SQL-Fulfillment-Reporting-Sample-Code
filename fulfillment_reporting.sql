--Purpose: Track how much of an order is fulfilled - Amount Sent is total items ordered,
-- Amount Closed includes all rejected/refunded items,
-- Amount Accepted includes all currently accepted items,
-- Order Amount contains the number of items ordered by the customer; 
-- once the amount accepted reaches order amount, the order will be fulfilled.
SELECT
		 "Orders"."Item Type" as "Item Type",
		 "Orders"."Customer Name" as "Customer Name",
		 "Orders"."Order Date" as "Order Date",
		 "Orders"."Order Name" as "Order Name",
		 "Orders"."Amount" as "Order Amount",
         -- Tracking rejected % so we can project how many purchases will ACTUALLY need to be made
         -- to completely fill an order
		 "Orders"."Rejected %" as "% Items Rejected",
		 COUNT(DISTINCT "Items"."Id") as "Amount Sent",
		 SUM(CASE
				 WHEN "Items"."Item Status"  = 'Rejected'
				 OR	"Items"."Item Status"  = 'Refunded' THEN 1
				 ELSE 0
			 END) as "Amount Closed",
		 SUM(CASE
				 WHEN "Items"."Item Status"  != 'Rejected'
				 AND	"Items"."Item Status"  != 'Refunded' THEN 1
				 ELSE 0
			 END) as "Amount Accepted",
		 "Orders"."Fulfillment Notes" as "Fulfillment Notes"
FROM  "Items"
LEFT JOIN "Orders" ON "Orders"."Id"  = "Items"."Order"
-- Removed all items in system that are marked as "test", in case any remain
WHERE	 lower_case("Items"."Full Name")  NOT LIKE '%test%'
-- Need to group by since we are using SUM
GROUP BY "Item Type",
	 "Order Name",
	 "Customer Name",
	 "Order Amount",
	 "% Items Rejected",
	 "Fulfillment Notes",
	 "Order Date" 
