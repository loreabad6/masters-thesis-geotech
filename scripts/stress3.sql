-- stress3

---------------------------------------------------
-- link_int
UPDATE  received.sa_ways SET ft_int_stress = 1, tf_int_stress = 1
WHERE   functional_class LIKE '%_link';