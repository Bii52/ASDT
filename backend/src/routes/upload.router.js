import express from 'express';
import { uploadImage } from '~/utils/upload.js';
import { uploadController } from '~/controllers/upload.controller.js';

const router = express.Router();

router.post('/avatar', uploadImage('avatar'), uploadController.uploadAvatar);

export const uploadRouter = router;