function [name,index] = doc_name(Dir)
contains = dir(Dir);
contains(1:2)=[];
n_subject = length(contains);
name = cell(n_subject,1);
index = name;
for i=1:n_subject
    name{i} = contains(i).name;
    index{i} = name{i}(2:end);
end
end