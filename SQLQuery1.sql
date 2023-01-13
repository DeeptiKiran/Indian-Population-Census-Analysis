SELECT * FROM SQL_Project.dbo.Data1;

SELECT * FROM SQL_Project.dbo.Data2;

--no. of rows in the dataset
SELECT COUNT(*) FROM SQL_Project..Data1;
SELECT COUNT(*) FROM SQL_Project..Data2;

--dataset for bihar and jharkhand
SELECT * FROM SQL_Project..Data1 WHERE STATE IN ('Bihar','Jharkhand');

--population in India
SELECT SUM(Population) AS Population FROM SQL_Project.dbo.Data2;

--avg. growth of India
SELECT AVG(Growth)*100 AS Avg_Growth FROM SQL_Project.dbo.Data1;

--avg. growth of States
SELECT State, AVG(Growth)*100 AS Avg_Growth FROM SQL_Project.dbo.Data1 GROUP BY State;

--avg. sex ratio
SELECT State, ROUND(AVG(Sex_Ratio),0) AS Avg_SexRatio FROM SQL_Project.dbo.Data1 GROUP BY State;

--states with highest-lowest  avg. sex ratio
SELECT State, ROUND(AVG(Sex_Ratio),0) AS Avg_SexRatio FROM SQL_Project.dbo.Data1 GROUP BY State ORDER BY Avg_SexRatio DESC;

--states with highest-lowest avg. literacy rate
SELECT State, ROUND(AVG(Literacy),0) AS Avg_Literacy FROM SQL_Project.dbo.Data1 GROUP BY State ORDER BY Avg_Literacy DESC;

--states with greater than 90 avg. literacy rate
SELECT State, ROUND(AVG(Literacy),0) AS Avg_Literacy FROM SQL_Project.dbo.Data1 GROUP BY State HAVING ROUND(AVG(Literacy),0)>90 ORDER BY Avg_Literacy DESC;

--top 3 states displaying highest growth rate
SELECT TOP 3 State, AVG(Growth)*100 AS Avg_growth FROM SQL_Project..Data1 GROUP BY State ORDER BY Avg_growth DESC;
--or
--SELECT State, AVG(Growth)*100 AS Avg_growth FROM SQL_Project..Data1 GROUP BY State ORDER BY Avg_growth DESC LIMIT 3;

--bottom 3 states displaying lowest sex ratio
SELECT TOP 3 State, ROUND(AVG(Sex_Ratio),0) AS Avg_SexRatio FROM SQL_Project..Data1 GROUP BY State ORDER BY Avg_SexRatio ASC;

--top and botom states in literacy rate
DROP TABLE IF EXISTS #top_states;
CREATE TABLE #top_states (states  nvarchar(255), topstates float)

INSERT INTO #top_states SELECT State, ROUND(AVG(Literacy),0) AS Avg_Literacy FROM SQL_Project..Data1 GROUP BY State ORDER BY Avg_Literacy DESC;

SELECT TOP 3 * FROM #top_states ORDER BY #top_states.topstates DESC;

DROP TABLE IF EXISTS #bottom_states;
CREATE TABLE #bottom_states (states  nvarchar(255), bottomstates float)

INSERT INTO #bottom_states SELECT State, ROUND(AVG(Literacy),0) AS Avg_Literacy FROM SQL_Project..Data1 GROUP BY State ORDER BY Avg_Literacy DESC;

SELECT TOP 3 * FROM #bottom_states ORDER BY #bottom_states.bottomstates ASC;

--union operator (joining outputs into vertical fashion)
SELECT * FROM (SELECT TOP 3 * FROM #top_states ORDER BY #top_states.topstates DESC) AS a
UNION
SELECT * FROM (SELECT TOP 3 * FROM #bottom_states ORDER BY #bottom_states.bottomstates ASC) AS b;

--states starting with letter a or b
SELECT DISTINCT State FROM SQL_Project..Data1 WHERE LOWER(State) LIKE 'a%' OR LOWER(State) LIKE 'b%';

--states starting with letter a or ending with letter d
SELECT DISTINCT State FROM SQL_Project..Data1 WHERE LOWER(State) LIKE 'a%' OR LOWER(State) LIKE '%d';

--states starting with letter a and ending with letter m
SELECT DISTINCT State FROM SQL_Project..Data1 WHERE LOWER(State) LIKE 'a%' AND LOWER(State) LIKE '%m';

--joining both tables
SELECT a.District, a.State, a.Sex_Ratio, b.Population from SQL_Project..Data1 a INNER JOIN SQL_Project..Data2 b ON a.District=b.District;

--total no. of males and females
SELECT c.District, c.State, ROUND(c.Population/(c.Sex_Ratio+1),0) Males, ROUND((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) Females FROM
(SELECT a.District, a.State, a.Sex_Ratio, b.Population from SQL_Project..Data1 a INNER JOIN SQL_Project..Data2 b ON a.District=b.District) c;

--total no. of males and females statewise
SELECT d.State, SUM(d.Males) Total_males, SUM(d.Females) Total_females FROM
(SELECT c.District, c.State, ROUND(c.Population/(c.Sex_Ratio+1),0) Males, ROUND((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) Females FROM
(SELECT a.District, a.State, a.Sex_Ratio/1000 Sex_ratio, b.Population from SQL_Project..Data1 a INNER JOIN SQL_Project..Data2 b ON a.District=b.District) c) d GROUP BY d.State;

--total no. of literate and illiterate people
SELECT d.State, SUM(Literate_people), SUM(Literate_people) FROM
(SELECT c.District, c.State, ROUND(c.Literacy_ratio*c.Population,0) Literate_people, ROUND((1-c.Literacy_ratio)*c.Population,0) Illiterate_people FROM
(SELECT a.District, a.State, a.Literacy/100 Literacy_ratio, b.Population from SQL_Project..Data1 a INNER JOIN SQL_Project..Data2 b ON a.District=b.District) c) d
GROUP BY d.State;

--population in previous census
select g.total_area/g.total_previous_population  as total_previous_population_vs_area,g.total_area/total_current_population as total_current_population_vs_area from
(SELECT q.*, r.total_area from

(select '1' as keyy,n.* from
(select sum(m.previous_census) total_previous_population,sum(m.current_census) total_current_population from
(select e.state,sum(e.previous_census) previous_census,sum(e.current_census) current_census from
(select c.State,c.District,round(c.population/(1+c.GROWTH),0) as previous_census,c.Population as current_census from
(SELECT a.District, a.State, a.Growth growth, b.Population from SQL_Project..Data1 a INNER JOIN SQL_Project..Data2 b ON a.District=b.District) c) e
group by e.state) m) n) q
INNER JOIN
(select '1' as keyy,z.* from
(select sum(area_km2) total_area  from SQL_Project..Data2) z) r on q.keyy=r.keyy) g

--top3 districts from each states having highest literacy rate 
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from SQL_Project..Data1)a
where rnk in (1,2,3) order by state