function findItem(arr, itemToFind)
	local foundIt = false
	local index = nil
	for i = 1, #arr, 1 do
		if arr[i] == itemToFind then
			foundIt = true
			index = i
			break
		end
	end
	if not foundIt then
		return foundIt
	else
		return index
	end
end

function findKey(obj, keyToFind)
	local foundIt = false
	local key = nil
	for k, v in pairs(obj) do
		if k == keyToFind then
			foundIt = true
			key = k
			break
		end
	end
	if not foundIt then
		return foundIt
	else
		return key
	end
end

function calcFinalPrice(shopCart, shopProfit, shopReduction)
	local shopProfitValue = 0
	local totalCartValue = 0

	for k, v in pairs(shopCart) do
		--print("k: " .. k)
		--print("v['price']: " .. v['price'])
		totalCartValue = totalCartValue + v['price']
	end
	shopCosts = 100 - shopProfit
	shopReductionValue = totalCartValue * (shopReduction / 100)
	totalWithReduction = totalCartValue - shopReductionValue
	shopProfitValue = totalWithReduction * (shopProfit / 100)
	shopCostValue = totalWithReduction * (shopCosts / 100)
	
	return shopCostValue, totalWithReduction
end