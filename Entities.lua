-- Clear code style 🧼🧽🧼🧽🌟🤩🤩✨✨
-- Чтобы не писать в 'game' for _, panda in ipairs(pandas) do panda:update() end

entities = {}

function entities:update(pandas)
	for _, panda in ipairs(pandas) do
		panda:update()
	end
end

function entities:draw(pandas)
	--trace('hahaha')
	--trace(pandas)
	for _, panda in ipairs(pandas) do
		
		panda:draw()
	end
end