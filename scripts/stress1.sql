-- stress1

---------------------------------------------------
-- motorway_trunk
UPDATE  received.sa_ways SET ft_seg_stress = NULL, tf_seg_stress = NULL
WHERE   functional_class IN ('motorway','motorway_link','trunk','trunk_link');

UPDATE  received.sa_ways SET ft_seg_stress = 3, tf_seg_stress = 3
WHERE   functional_class IN ('motorway','motorway_link','trunk','trunk_link');

---------------------------------------------------
-- higher_order
-- Find it as 'stress_higher_order_ways' function in stress.R 
-- Things changed: speeds - 40mph=70kmh 35mph=60kmh 30mph=50kmh 25mph=40kmh 20mph=30kmh, width - 15ft=5m 13ft=4m 8ft=2.5m 5ft=1.5m 27ft=8m 19ft=6m

---------------------------------------------------
-- lower_order
-- Find it as 'stress_lower_order_ways' function in stress.R 
-- Remark: why do they use default_lanes if the function does not use it?