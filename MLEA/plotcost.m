clf;hold on;
color = 'g'
file = 'c:\console_999.txt';
d = csvread(file);plot(d(:,1), d(:, 2), color);plot(d(:,1), d(:, 3), color);
d = csvread('c:\console_3.txt');plot(d(:,1), d(:, 2), 'g');plot(d(:,1), d(:, 3) .* 1, 'g');;plot(d(:,1), d(:, 4), 'g');

d2 = csvread('c:\2.txt');plot(d2(:,1), d2(:, 2) .* 1, 'g');plot(d2(:,1), d2(:, 3) .* 1, 'g');
d3 = csvread('c:\3.txt');plot(d3(:,1), d3(:, 2) .* 1, 'b');plot(d3(:,1), d3(:, 3) .* 1, 'b');
d4 = csvread('c:\4.txt');plot(d4(:,1), d4(:, 2) .* 1, 'c');plot(d4(:,1), d4(:, 3) .* 1, 'c');
d5 = csvread('c:\5.txt');plot(d5(:,1), d5(:, 2) .* 1, 'm');

d6 = csvread('c:\6.txt');plot(d6(:,1), d6(:, 2) .* 1, 'm');plot(d6(:,1), d6(:, 3) .* 1, 'm');
d7 = csvread('c:\7.txt');plot(d7(:,1), d7(:, 2) .* 1, 'g');plot(d7(:,1), d7(:, 3) .* 1, 'g');
d8 = csvread('c:\8.txt');plot(d8(:,1), d8(:, 2) .* 1, 'b');plot(d8(:,1), d8(:, 3) .* 1, 'b');
d9 = csvread('c:\9.txt');plot(d9(:,1), d9(:, 2) .* 1, 'c');plot(d9(:,1), d9(:, 3) .* 1, 'c');

dm = csvread('c:\dm.txt');plot(dm(:,1), -(dm(:, 2)-1000000), 'b');
plot(dm(:,1), dm(:,3));

d0 = csvread('c:\0.txt');plot(d0(:, 3), 'r');plot(d0(:, 4) .* 1, 'r');
set(gca(),'xticklabel',d0(:, 1))
