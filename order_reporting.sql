SELECT
		-- Add zcrm_ at the beginning, as ids are a long string of numbers that can be cutoff when exported to csv file
		 'zcrm_' + ite."Id" as "id",
		 ord."Order Status" as "Order Status",
		 ite."Item Name" as "Item Name",
		 ord."Order Name" as "Order",
		 ite."Item Type" as "Item Type",
		 ite."Item Status" as "Item Status",
		 ite."Pending Processing Reason(s)" as "Pending Processing Reason(s)",
		 ite."Rejected Shipment Reason(s)" as "Rejected Shipment Reason",
		 ite."Business Name" as "Business Name",
		 ite."Date Ordered By Customer" as "Date Ordered By Customer",
		 ite."Date Ordered From Vendor" as "Date Ordered From Vendor",
		 ite."Order Fulfilled" as "Order Fulfilled",
		 ite."Payment Received" as "Payment Received",
		 ve."Vendor Name" as "Vendor",
		 -- Reformatting dates below in order to make calculations cleaner and in a more consistent format; was not
		 --	dont on date ordered above, since we want the dates in their original format, as we are not doing any calculations
		 --	with them.
		 date_format(ite."Date Ordered From Vendor", '%Y%m%d') * 1 as "Date Ordered From Vendor",
		 date_format(ite."Date Ordered By Customer", '%Y%m%d') * 1 as "Date Ordered by Customer"
		 if(date_format(ite."Date Ordered From Vendor", '%Y%m') * 100 + 1  = date_format(today(), '%Y%m') * 100 + 1, 1, 0) as "Ordered From Vendor MTD",
		 if(date_format(ite."Date Ordered By Customer", '%Y%m%d') * 1  >= date_format(today() -7, '%Y%m%d') * 1, 1, 0) as "Ordered by Customer Last 7 Days",
		 if(date_format(ite."Date Ordered From Vendor", '%Y%m%d') * 1  >= date_format(today() -7, '%Y%m%d') * 1, 1, 0) as "Ordered From Vendor Last 7 Days",
		 if(date_format(ite."Date Ordered From Vendor", '%Y%m%d') * 1  = date_format(yesterday(), '%Y%m%d') * 1, 1, 0) as "Ordered From Vendor Yesterday",
		 if(date_format(ite."Date Ordered From Vendor", '%Y%m%d') * 1  = date_format(today(), '%Y%m%d') * 1, 1, 0) as "Ordered From Vendor Today",
		 -- If we have received and order from the customer that needs to be fulfilled, but we have not ordered anything
		 -- from our vendor to fill it with, this will be marked as "1" so we can filter out the ones that still need attention.
		 -- Can also be summed to see how many orders still need to be place with vendors to fulfill all orders from customers.
		 if(ite."Item Status"  != 'Rejected'
		 AND	ite."Date Ordered From Vendor"  = NULL, 1, 0) as "Needs to be Ordered From Vendor"
FROM  "Items" AS  'ite'
-- Join order to include information on what order the item is going TOWARDS.
-- Join vendor to include information on the vendor we ordered FROM to fulfill the order
LEFT JOIN "Order" ord ON ord."Id"  = ite."Order" 
LEFT JOIN "Vendors" ve ON ve.id  = ite."Vendor"  
-- Filter by any item type that include "Clothing", as that is what we are currently tracking fulfillment on
WHERE	 ite."Item Type"  LIKE 'Clothing'
