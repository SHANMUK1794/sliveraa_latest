-- CreateEnum
CREATE TYPE "SavingsFrequency" AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY');

-- CreateEnum
CREATE TYPE "KycStatus" AS ENUM ('NOT_STARTED', 'PENDING', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM ('BUY', 'SELL', 'DEPOSIT', 'WITHDRAWAL', 'REWARD');

-- CreateEnum
CREATE TYPE "MetalType" AS ENUM ('GOLD', 'SILVER');

-- CreateEnum
CREATE TYPE "TransactionStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "name" TEXT,
    "email" TEXT,
    "password" TEXT,
    "referralCode" TEXT NOT NULL,
    "referredBy" TEXT,
    "kycStatus" "KycStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "walletBalance" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "goldBalance" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "silverBalance" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Address" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "label" TEXT NOT NULL DEFAULT 'Home',
    "line1" TEXT NOT NULL,
    "line2" TEXT,
    "city" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "pincode" TEXT NOT NULL,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Address_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DeliveryRequest" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "addressId" TEXT NOT NULL,
    "metalType" "MetalType" NOT NULL,
    "weight" DOUBLE PRECISION NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "trackingId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DeliveryRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SavingsPlan" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "metalType" "MetalType" NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "frequency" "SavingsFrequency" NOT NULL DEFAULT 'MONTHLY',
    "dayOfWeek" INTEGER,
    "dayOfMonth" INTEGER,
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "nextPaymentDate" TIMESTAMP(3) NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SavingsPlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reward" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "points" DOUBLE PRECISION NOT NULL,
    "description" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'REFERRAL',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Reward_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OtpVerification" (
    "id" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "intent" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OtpVerification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "KycDetail" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "documentType" TEXT NOT NULL,
    "documentNumber" TEXT NOT NULL,
    "verificationId" TEXT,
    "status" "KycStatus" NOT NULL DEFAULT 'PENDING',
    "rawResponse" JSONB,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "KycDetail_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "TransactionType" NOT NULL,
    "metalType" "MetalType",
    "amount" DOUBLE PRECISION NOT NULL,
    "weight" DOUBLE PRECISION,
    "pricePerUnit" DOUBLE PRECISION,
    "status" "TransactionStatus" NOT NULL DEFAULT 'PENDING',
    "razorpayOrderId" TEXT,
    "razorpayPaymentId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MetalPrice" (
    "id" TEXT NOT NULL,
    "metalType" "MetalType" NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "source" TEXT NOT NULL DEFAULT 'goldapi.io',
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MetalPrice_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_phoneNumber_key" ON "User"("phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_referralCode_key" ON "User"("referralCode");

-- CreateIndex
CREATE INDEX "OtpVerification_phoneNumber_idx" ON "OtpVerification"("phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "KycDetail_userId_key" ON "KycDetail"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Transaction_razorpayOrderId_key" ON "Transaction"("razorpayOrderId");

-- CreateIndex
CREATE UNIQUE INDEX "Transaction_razorpayPaymentId_key" ON "Transaction"("razorpayPaymentId");

-- CreateIndex
CREATE UNIQUE INDEX "MetalPrice_metalType_key" ON "MetalPrice"("metalType");

-- AddForeignKey
ALTER TABLE "Address" ADD CONSTRAINT "Address_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DeliveryRequest" ADD CONSTRAINT "DeliveryRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DeliveryRequest" ADD CONSTRAINT "DeliveryRequest_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SavingsPlan" ADD CONSTRAINT "SavingsPlan_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reward" ADD CONSTRAINT "Reward_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KycDetail" ADD CONSTRAINT "KycDetail_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
