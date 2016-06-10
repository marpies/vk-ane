package com.marpies.utils {

    import feathers.layout.AnchorLayoutData;

    import starling.display.DisplayObject;

    public class AnchorLayoutDataBuilder {

        private var mLayoutData:AnchorLayoutData;

        public function AnchorLayoutDataBuilder() {
            mLayoutData = new AnchorLayoutData();
        }

        public function setTop( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.top = value;
            return this;
        }

        public function setRight( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.right = value;
            return this;
        }

        public function setBottom( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.bottom = value;
            return this;
        }

        public function setLeft( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.left = value;
            return this;
        }

        public function setTopAnchorObject( value:DisplayObject ):AnchorLayoutDataBuilder {
            mLayoutData.topAnchorDisplayObject = value;
            return this;
        }

        public function setRightAnchorObject( value:DisplayObject ):AnchorLayoutDataBuilder {
            mLayoutData.rightAnchorDisplayObject = value;
            return this;
        }

        public function setBottomAnchorObject( value:DisplayObject ):AnchorLayoutDataBuilder {
            mLayoutData.bottomAnchorDisplayObject = value;
            return this;
        }

        public function setLeftAnchorObject( value:DisplayObject ):AnchorLayoutDataBuilder {
            mLayoutData.leftAnchorDisplayObject = value;
            return this;
        }

        public function setPercentWidth( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.percentWidth = value;
            return this;
        }

        public function setPercentHeight( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.percentHeight = value;
            return this;
        }

        public function setHorizontalCenter( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.horizontalCenter = value;
            return this;
        }

        public function setVerticalCenter( value:Number ):AnchorLayoutDataBuilder {
            mLayoutData.verticalCenter = value;
            return this;
        }

        public function build():AnchorLayoutData {
            return mLayoutData;
        }

    }

}
