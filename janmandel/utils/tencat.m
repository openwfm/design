function c=tencat(a,b)
% c=tencat(a,b)
c=reshape(a(:)*b(:).',[size(a),size(b)]);