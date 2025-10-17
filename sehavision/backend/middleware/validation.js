const Joi = require('joi');

const validateRequest = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: 'Validation error',
                details: error.details.map(detail => detail.message)
            });
        }
        next();
    };
};

// Validation schemas
const schemas = {
    register: Joi.object({
        email: Joi.string().email().required(),
        password: Joi.string().min(6).required(),
        name: Joi.string().min(2).required(),
        phone: Joi.string().optional()
    }),

    login: Joi.object({
        email: Joi.string().email().required(),
        password: Joi.string().required()
    }),

    medicine: Joi.object({
        name: Joi.string().min(2).required(),
        brand: Joi.string().optional(),
        barcode: Joi.string().optional(),
        dosage: Joi.string().optional(),
        instructions: Joi.string().optional(),
        warnings: Joi.string().optional(),
        interactions: Joi.string().optional(),
        expiry_date: Joi.date().optional(),
        image_paths: Joi.string().optional()
    }),

    reminder: Joi.object({
        medicine_id: Joi.number().integer().positive().required(),
        title: Joi.string().min(2).required(),
        description: Joi.string().optional(),
        scheduled_time: Joi.date().required(),
        frequency: Joi.string().valid('once', 'daily', 'weekly', 'monthly').default('once')
    }),

    interactionCheck: Joi.object({
        medicine_ids: Joi.array().items(Joi.number().integer().positive()).min(2).required()
    }),

    interaction: Joi.object({
        medicine1_id: Joi.number().integer().positive().required(),
        medicine2_id: Joi.number().integer().positive().required(),
        interaction_type: Joi.string().required(),
        severity: Joi.string().valid('low', 'moderate', 'high', 'severe').required(),
        description: Joi.string().optional()
    })
};

module.exports = {
    validateRequest,
    schemas
};
